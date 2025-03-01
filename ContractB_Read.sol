// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ICrossChainRouter.sol";

contract ContractB_Read {
    ICrossChainRouter public router;
    uint256 public retrievedValue;

    constructor(address _router) {
        router = ICrossChainRouter(_router);
    }

    function requestValue(bytes32 targetChainId, address targetContract) public {
        ICrossChainRouter.ExternalContract memory target = ICrossChainRouter.ExternalContract({
            contractAddress: targetContract,
            functionSelector: bytes4(keccak256("getValue()")),
            params: ""
        });

        ICrossChainRouter.Callback memory callback = ICrossChainRouter.Callback({
            chain: ICrossChainRouter.Blockchain(targetChainId, ""),
            callbackAddress: address(this),
            callbackSelector: bytes4(keccak256("handleResult(uint256)"))
        });

        router.initiateCrossChainCall(targetChainId, target, callback);
    }

    function handleResult(uint256 value) external {
        retrievedValue = value;
    }
}
