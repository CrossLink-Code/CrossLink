// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ICrossChainRouter {
    
    struct Blockchain {
        bytes32 chainId; // Unique identifier (e.g., "ETH_MAINNET")
        string rpcEndpoint; // Optional: For dynamic queries
    }

    struct ExternalContract {
        address contractAddress;
        bytes4 functionSelector; // Function selector (e.g., keccak256("transfer(address,uint256)"))
        bytes params; // ABI-encoded parameters
    }

    struct CrossChainCall {
        bytes32 requestId; // Unique identifier for tracking
        address sender; // Origin chain caller address
        ExternalContract targetContract;
        Callback callback; 
    }

    struct Callback {
        Blockchain chain; // Destination chain details
        address callbackAddress; // Contract to handle the response
        bytes4 callbackSelector; // Function selector for callback
    }

    event CrossChainRequest(
        bytes32 indexed requestId,
        Blockchain targetChain,
        CrossChainCall crossChainCall
    );

    event CallBackResult(
        bytes32 indexed requestId,
        bool success,
        bytes result
    );

    function initiateCrossChainCall(
        bytes32 _targetChainId,
        ExternalContract calldata _targetContract,
        Callback calldata _callback
    ) external payable;

    function handleIncoming(CrossChainCall calldata crossChainCall) external;

    function chainId() external view returns (bytes32);
}
