// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract CryptBoundArena {
    struct Run {
        address player;
        uint8 floor;
        uint16 playerHp;
        uint16 bossHp;
        bytes32 bossCommit;
        uint256 relicSeed;
        bool active;
    }

    mapping(address => Run) public runs;
    mapping(address => bytes32[]) public playerRelics;

    event RunStarted(address indexed player, bytes32 initialBossCommit);
    event TurnResolved(
        address indexed player,
        uint8 playerAction,
        uint8 bossAction,
        uint16 playerHp,
        uint16 bossHp,
        bytes32 nextBossCommit
    );
    event RelicForged(address indexed player, bytes32 indexed relicId, uint8 floor);

    function startRun(bytes32 _initialBossCommit) external {
        runs[msg.sender] = Run({
            player: msg.sender,
            floor: 1,
            playerHp: 100,
            bossHp: 100,
            bossCommit: _initialBossCommit,
            relicSeed: uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, _initialBossCommit))),
            active: true
        });
        emit RunStarted(msg.sender, _initialBossCommit);
    }

    // Actions: 0 = Strike, 1 = Aegis Guard, 2 = Arcane Counter
    function resolveTurn(
        uint8 _playerAction,
        uint8 _revealedBossAction,
        bytes32 _salt,
        bytes32 _nextBossCommit
    ) external {
        Run storage r = runs[msg.sender];
        require(r.active, "No active run");
        require(_playerAction < 3 && _revealedBossAction < 3, "Invalid action");

        require(
            keccak256(abi.encodePacked(_revealedBossAction, _salt)) == r.bossCommit,
            "Commitment mismatch: cheat detected"
        );

        if (_playerAction == _revealedBossAction) {
            r.playerHp = r.playerHp > 10 ? r.playerHp - 10 : 0;
            r.bossHp = r.bossHp > 10 ? r.bossHp - 10 : 0;
        } else if (
            (_playerAction == 0 && _revealedBossAction == 2) ||
            (_playerAction == 1 && _revealedBossAction == 0) ||
            (_playerAction == 2 && _revealedBossAction == 1)
        ) {
            uint16 dmg = 35;
            r.bossHp = r.bossHp > dmg ? r.bossHp - dmg : 0;
        } else {
            uint16 dmg = 25;
            r.playerHp = r.playerHp > dmg ? r.playerHp - dmg : 0;
        }

        r.relicSeed = uint256(keccak256(abi.encodePacked(r.relicSeed, _playerAction, _salt)));
        r.bossCommit = _nextBossCommit;

        if (r.bossHp == 0) {
            bytes32 relicId = keccak256(abi.encodePacked(r.relicSeed, r.floor));
            playerRelics[msg.sender].push(relicId);
            emit RelicForged(msg.sender, relicId, r.floor);

            r.floor += 1;
            r.bossHp = 100 + (uint16(r.floor - 1) * 25);
            r.playerHp = r.playerHp + 30 > 100 ? 100 : r.playerHp + 30;
        } else if (r.playerHp == 0) {
            r.active = false;
        }

        emit TurnResolved(msg.sender, _playerAction, _revealedBossAction, r.playerHp, r.bossHp, _nextBossCommit);
    }

    function getRelics(address _player) external view returns (bytes32[] memory) {
        return playerRelics[_player];
    }
}
