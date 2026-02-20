// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/access/Ownable.sol";

contract FTDSoulbound is ERC721, Ownable {
    uint256 public nextId = 1;

    // 1 SBT max par étudiant (actif)
    mapping(address => bool) public hasMinted;

    // Infos cohorte
    string public programName;
    uint256 public cohortYear;

    // URI du metadata IPFS (cohorte)
    string private _cohortURI;

    event Minted(address indexed student, uint256 indexed tokenId);
    event CohortURIUpdated(string newURI);
    event Revoked(uint256 indexed tokenId, address indexed student);

    constructor(string memory _programName, uint256 _cohortYear)
        ERC721("FTD Soulbound Token", "FTDSBT")
        Ownable(msg.sender)
    {
        programName = _programName;
        cohortYear = _cohortYear;

        _cohortURI = "ipfs://bafkreicpstfrprvxpoumwqunxjquyyzt6ujz66dtf5dzlgvg4xynu2yidy";
    }

    function mint(address student) external onlyOwner {
        require(student != address(0), "Invalid student");
        require(!hasMinted[student], "Already minted");
        _mintProcess(student);
    }

    function mintBatch(address[] calldata students) external onlyOwner {
        uint256 len = students.length;
        require(len > 0, "Empty list");

        for (uint256 i = 0; i < len; i++) {
            address student = students[i];
            if (student == address(0) || hasMinted[student]) continue;
            _mintProcess(student);
        }
    }

    function _mintProcess(address student) internal {
        uint256 tokenId = nextId++;
        hasMinted[student] = true;
        _safeMint(student, tokenId);
        emit Minted(student, tokenId);
    }

    // Révocation (burn) + permet la réémission (hasMinted redevient false)
    function revoke(uint256 tokenId) external onlyOwner {
        address student = ownerOf(tokenId); // revert si token inexistant
        hasMinted[student] = false;
        _burn(tokenId);
        emit Revoked(tokenId, student);
    }

    function setCohortURI(string calldata newURI) external onlyOwner {
        require(bytes(newURI).length > 0, "Empty URI");
        _cohortURI = newURI;
        emit CohortURIUpdated(newURI);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "Nonexistent token");
        return _cohortURI;
    }

    // Soulbound: block transfers, allow mint (from=0) and burn (to=0)
    function _update(address to, uint256 tokenId, address auth)
        internal
        override
        returns (address)
    {
        address from = _ownerOf(tokenId);
        if (from != address(0) && to != address(0)) {
            revert("Soulbound: transfers disabled");
        }
        return super._update(to, tokenId, auth);
    }
}
