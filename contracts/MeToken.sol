// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

abstract contract Owned {
    address payable owner;

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }
}

abstract contract Mortal is Owned {
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }
}


contract MeToken is ERC20, Mortal {
    using SafeMath for uint256;

    address[] internal stakeholders;

    mapping(address => uint256) stakes;

    mapping(address => uint256) rewards;

    constructor(uint256 initialSupply) ERC20("MeToken", "MET") {
        _mint(msg.sender, initialSupply);
    }

    function withdraw() public {
        require(this.balanceOf(address(this)) > 5000, "This Faucet have 5000 tokens, so why cant send you tokens");
        this.transfer(msg.sender, 1000);
    }

    function isStakeholder(address _address) public view returns (bool, uint256) {
        for (uint256 i = 0; i < stakeholders.length; i += 1) {
            if (_address == stakeholders[i]) return (true, i);
        }
        return (false, 0);
    }

    function addStakeholder(address _address) public {
        (bool _isStakeholder,) = isStakeholder(_address);
        if (!_isStakeholder) stakeholders.push(_address);
    }

    function removeStakeholder(address _address) public onlyOwner {
        (bool _isStakeholder, uint256 i) = isStakeholder(_address);
        if (_isStakeholder) {
            stakeholders[i] = stakeholders[stakeholders.length - 1];
        }
    }

    function stakeOf(address _stakeholder) public view returns (uint256){
        return stakes[_stakeholder];
    }

    function totalStakes() public view returns (uint256) {
        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1) {
            _totalStakes = _totalStakes.add(stakes[stakeholders[s]]);
        }
        return _totalStakes;
    }

    function createStake(uint256 _stakes) public {
        _burn(msg.sender, _stakes);
        if (stakes[msg.sender] == 0) addStakeholder(msg.sender);
        stakes[msg.sender] = stakes[msg.sender].add(_stakes);
    }


    function removeStake(uint256 _stakes) public {
        stakes[msg.sender] = stakes[msg.sender].sub(_stakes);
        if (stakes[msg.sender] != 0) removeStakeholder(msg.sender);
        _mint(msg.sender, _stakes);
    }


    function rewardOf(address _address) public view returns (uint256){
        return rewards[_address];
    }


    function totalRewards() public view returns (uint256){
        uint256 _totalRewards = 0;
        for (uint256 i; i < stakeholders.length; i += 1) {
            _totalRewards = _totalRewards.add(rewards[stakeholders[i]]);
        }
        return _totalRewards;
    }


    function computeRewards(address _stakeholder) public view returns (uint256){
        return stakes[_stakeholder] / 100;
    }


    function distributeRewards() public onlyOwner {
        for (uint256 s = 0; s < stakeholders.length; s += 1) {
            address stakeholder = stakeholders[s];
            uint256 reward = computeRewards(stakeholder);
            rewards[stakeholder] = rewards[stakeholder].add(reward);
        }
    }

    function withdrawReward() public {
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        _mint(msg.sender, reward);
    }

}