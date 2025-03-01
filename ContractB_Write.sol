// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ICrossChainRouter.sol";

contract ContractB_Write {
    ICrossChainRouter public router;
    bool public writeSuccessful;

    constructor(address _router) {
        router = ICrossChainRouter(_router);
    }

    function updateRemoteValue(bytes32 targetChainId, address targetContract, uint256 newValue) public {
        ICrossChainRouter.ExternalContract memory target = ICrossChainRouter.ExternalContract({
            contractAddress: targetContract,
            functionSelector: bytes4(keccak256("setValue(uint256)")),
            params: abi.encode(newValue)
        });

        ICrossChainRouter.Callback memory callback = ICrossChainRouter.Callback({
            chain: ICrossChainRouter.Blockchain(targetChainId, ""),
            callbackAddress: address(this),
            callbackSelector: bytes4(keccak256("handleWriteResult(bool)"))
        });

        router.initiateCrossChainCall(targetChainId, target, callback);
    }

    function handleWriteResult(bool success) external {
        writeSuccessful = success;
    }
}
