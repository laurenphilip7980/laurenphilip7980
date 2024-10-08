// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

interface ISubmission {
    struct Haiku {
        address author;
        string line1;
        string line2;
        string line3;
    }

    function mintHaiku(
        string memory _line1,
        string memory _line2,
        string memory _line3,
string memory _line4
    ) external;

    function shareHaiku(uint256 _id, address _to) external;

    function getMySharedHaikus() external view returns (Haiku[] memory);
}

contract HaikuNFT is ERC721, ISubmission {
    Haiku[] public haikus;
    mapping(address => mapping(uint256 => bool)) public sharedHaikus;
    uint256 public haikuCounter;

    constructor() ERC721("HaikuNFT", "HAIKU") {
        haikuCounter = 1;
    }

    function mintHaiku(
        string memory _line1,
        string memory _line2,
        string memory _line3
    ) external override {
        // Check if the haiku is unique
        for (uint256 i = 0; i < haikus.length; i++) {
            Haiku memory existingHaiku = haikus[i];
            if (
                keccak256(abi.encodePacked(existingHaiku.line1)) ==
                keccak256(abi.encodePacked(_line1)) &&
                keccak256(abi.encodePacked(existingHaiku.line2)) ==
                keccak256(abi.encodePacked(_line2)) &&
                keccak256(abi.encodePacked(existingHaiku.line3)) ==
                keccak256(abi.encodePacked(_line3))
            ) {
                revert HaikuNotUnique();
            }
        }

        // Mint the haiku NFT
        _safeMint(msg.sender, haikuCounter);
        haikus.push(Haiku(msg.sender, _line1, _line2, _line3));
        haikuCounter++;
    }

    function shareHaiku(uint256 _id, address _to) external override {
        require(_id > 0 && _id <= haikuCounter, "Invalid haiku ID");
        require(ownerOf(_id) == msg.sender, "Not your haiku");
        sharedHaikus[_to][_id] = true;
    }

    function getMySharedHaikus()
        external
        view
        override
        returns (Haiku[] memory)
    {
        uint256 sharedHaikuCount;
        for (uint256 i = 0; i < haikus.length; i++) {
            if (sharedHaikus[msg.sender][i + 1]) {
                sharedHaikuCount++;
            }
        }

        require(sharedHaikuCount > 0, "No haikus shared");

        Haiku[] memory result = new Haiku[](sharedHaikuCount);
        uint256 currentIndex;
        for (uint256 i = 0; i < haikus.length; i++) {
            if (sharedHaikus[msg.sender][i + 1]) {
                result[currentIndex] = haikus[i];
                currentIndex++;
            }
        }

        return result;
    }

    error HaikuNotUnique();
}
