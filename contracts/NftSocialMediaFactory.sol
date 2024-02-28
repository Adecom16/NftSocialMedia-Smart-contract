// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTSocialMediaPlatform.sol";

contract NFTSocialMediaFactory { 
    address[] public deployedPlatforms;

    event PlatformDeployed(address indexed platformAddress, address indexed creator);

    function deployPlatform() public {
        address newPlatform = address(new NFTSocialMediaPlatform());
        deployedPlatforms.push(newPlatform);
        emit PlatformDeployed(newPlatform, msg.sender);
    }

    function getDeployedPlatforms() public view returns (address[] memory) {
        return deployedPlatforms;
    }
}
