// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/access/Ownable.sol";

contract FTDSoulbound is ERC721, Ownable {
    uint256 public nextId = 1;

    // 1 SBT max par étudiant
    mapping(address => bool) public hasMinted;

    // Infos cohorte
    string public programName;
    uint256 public cohortYear;

    // URI du metadata IPFS (cohorte)
    string private _cohortURI;

    event Minted(address indexed student, uint256 indexed tokenId);
    event CohortURIUpdated(string newURI);
    event Revoked(uint256 indexed tokenId);

    constructor(string memory _programName, uint256 _cohortYear)
        ERC721("FTD Soulbound Token", "FTDSBT")
        Ownable(msg.sender)
    {
        programName = _programName;
        cohortYear = _cohortYear;

        // CID metadata.json (cohorte)
        _cohortURI = "ipfs://bafkreicpstfrprvxpoumwqunxjquyyzt6ujz66dtf5dzlgvg4xynu2yidy";
    }

    function mint(address student) external onlyOwner {
        require(student != address(0), "Invalid student");
        require(!hasMinted[student], "Already minted");

        uint256 tokenId = nextId++;
        hasMinted[student] = true;

        _safeMint(student, tokenId);
        emit Minted(student, tokenId);
    }

    // Mint en batch (cohorte)
    function mintBatch(address[] calldata students) external onlyOwner {
        uint256 len = students.length;
        require(len > 0, "Empty list");

        for (uint256 i = 0; i < len; i++) {
            address student = students[i];

            // On ignore les adresses invalides / déjà mintées (ne revert pas tout le batch)
            if (student == address(0) || hasMinted[student]) {
                continue;
            }

            uint256 tokenId = nextId++;
            hasMinted[student] = true;

            _safeMint(student, tokenId);
            emit Minted(student, tokenId);
        }
    }

    // Permet de changer le metadata si nécessaire (nouveau CID)
    function setCohortURI(string calldata newURI) external onlyOwner {
        _cohortURI = newURI;
        emit CohortURIUpdated(newURI);
    }

    // Retourne le metadata IPFS (même URI pour tous les tokens de la cohorte)
    function tokenURI(uint256) public view override returns (string memory) {
        return _cohortURI;
    }

    // Révocation (burn) par l'institution
    function revoke(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
        emit Revoked(tokenId);
    }

    // Block all transfers (soulbound behavior)
    function _update(address to, uint256 tokenId, address auth)
        internal
        override
        returns (address)
    {
        address from = _ownerOf(tokenId);

        // allow mint (from=0) and burn (to=0), block transfers otherwise
        if (from != address(0) && to != address(0)) {
            revert("Soulbound: transfers disabled");
        }

        return super._update(to, tokenId, auth);
    }
}

