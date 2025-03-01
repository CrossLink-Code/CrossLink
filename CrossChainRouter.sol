// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ICrossChainRouter.sol";

contract CrossChainRouter is ICrossChainRouter {
    mapping(bytes32 => Blockchain) public blockchains;
    bytes32 public immutable routerChainId;

    constructor(bytes32 _chainId) {
        routerChainId = _chainId;
    }

    function chainId() external view override returns (bytes32) {
        return routerChainId;
    }

    function initiateCrossChainCall(
        bytes32 _targetChainId,
        ExternalContract calldata _targetContract,
        Callback calldata _callback
    ) external payable override {
        bytes32 requestId = keccak256(abi.encodePacked(block.timestamp, msg.sender));

        emit CrossChainRequest(
            requestId,
            blockchains[_targetChainId],
            CrossChainCall({
                requestId: requestId,
                sender: msg.sender,
                targetContract: _targetContract,
                callback: _callback
            })
        );
    }

    function handleIncoming(CrossChainCall calldata crossChainCall) external override {
        require(crossChainCall.targetContract.contractAddress != address(0), "Invalid contract address");

        (bool success, bytes memory returnData) = crossChainCall.targetContract.contractAddress.call(
            abi.encodePacked(crossChainCall.targetContract.functionSelector, crossChainCall.targetContract.params)
        );

        if (success) {
            if (crossChainCall.callback.callbackAddress == address(0)) {
                return;
            }

            if (crossChainCall.callback.chain.chainId == routerChainId) {
                (bool status, bytes memory result) = crossChainCall.callback.callbackAddress.call(
                    abi.encodePacked(crossChainCall.callback.callbackSelector, returnData)
                );
                emit CallBackResult(crossChainCall.requestId, status, result);
            } else {
                ExternalContract memory extContract = ExternalContract({
                    contractAddress: crossChainCall.callback.callbackAddress,
                    functionSelector: crossChainCall.callback.callbackSelector,
                    params: returnData
                });

                this.initiateCrossChainCall(
                    crossChainCall.callback.chain.chainId,
                    extContract,
                    Callback({ chain: Blockchain(bytes32(0), ""), callbackAddress: address(0), callbackSelector: bytes4(0) })
                );
            }
        }
    }
}
