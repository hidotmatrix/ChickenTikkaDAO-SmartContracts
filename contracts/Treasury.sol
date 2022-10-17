// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract Treasury is Ownable, ERC721Holder {

    constructor() {}
 
    // function to withdraw NFTs from treasury
    function withdrawNFT(uint256[] calldata _tokenIds,address[] calldata _nftAddresses, address _recepient) external onlyOwner {
        for(uint256 i=0;i<_tokenIds.length;i++){
          IERC721(_nftAddresses[i]).transferFrom(address(this), _recepient , _tokenIds[i]);
        }
    }

    // function to withdraw ERC20 token assets from treasury
    function withdrawERC20s(uint256[] calldata _amounts,address[] calldata _tokenAddresses, address _recepient) external onlyOwner {
        for(uint256 i=0;i<_amounts.length;i++){
          IERC20(_tokenAddresses[i]).transferFrom(address(this), _recepient , _amounts[i]);
        }
    }

}