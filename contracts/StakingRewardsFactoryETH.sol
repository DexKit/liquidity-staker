pragma solidity ^0.5.16;

import 'openzeppelin-solidity-2.3.0/contracts/token/ERC20/IERC20.sol';
import 'openzeppelin-solidity-2.3.0/contracts/ownership/Ownable.sol';

import './StakingRewardsETH.sol';

contract StakingRewardsFactoryETH is Ownable {
    // immutables
    address payable public rewardsToken;
    uint public stakingRewardsGenesis;

    // the staking tokens for which the rewards contract has been deployed
    address[] public stakingTokens;

    // info about rewards for a particular staking token
    struct StakingRewardsInfo {
        address payable stakingRewards;
        uint rewardAmount;
    }

    // rewards info by staking token
    mapping(address => StakingRewardsInfo) public stakingRewardsInfoByStakingToken;

    constructor(
        address payable _rewardsToken,
        uint _stakingRewardsGenesis
    ) Ownable() public {
        require(_stakingRewardsGenesis >= block.timestamp, 'StakingRewardsFactoryETH::constructor: genesis too soon');

        rewardsToken = _rewardsToken;
        stakingRewardsGenesis = _stakingRewardsGenesis;
    }

    ///// permissioned functions

    // deploy a staking reward contract for the staking token, and store the reward amount
    // the reward will be distributed to the staking reward contract no sooner than the genesis
    function deploy(address stakingToken, uint rewardAmount) public onlyOwner {
        StakingRewardsInfo storage info = stakingRewardsInfoByStakingToken[stakingToken];
        require(info.stakingRewards == address(0), 'StakingRewardsFactoryETH::deploy: already deployed');

        info.stakingRewards = address(new StakingRewardsETH(/*_rewardsDistribution=*/ address(this), rewardsToken, stakingToken));
        info.rewardAmount = rewardAmount;
        stakingTokens.push(stakingToken);
    }

    ///// permissionless functions

    // call notifyRewardAmount for all staking tokens.
    function notifyRewardAmounts() public {
        require(stakingTokens.length > 0, 'StakingRewardsFactoryETH::notifyRewardAmounts: called before any deploys');
        for (uint i = 0; i < stakingTokens.length; i++) {
            notifyRewardAmount(stakingTokens[i]);
        }
    }

     // call notifyRewardAmountFrom for all staking tokens.
    function notifyRewardAmountsFrom(address rewardsFrom) public {
        require(stakingTokens.length > 0, 'StakingRewardsFactoryETH::notifyRewardAmountsFrom: called before any deploys');
        for (uint i = 0; i < stakingTokens.length; i++) {
            notifyRewardAmountFrom(stakingTokens[i], rewardsFrom);
        }
    }

    // notify reward amount for an individual staking token.
    // this is a fallback in case the notifyRewardAmounts costs too much gas to call for all contracts
    function notifyRewardAmount(address stakingToken) public {
        require(block.timestamp >= stakingRewardsGenesis, 'StakingRewardsFactoryETH::notifyRewardAmount: not ready');

        StakingRewardsInfo storage info = stakingRewardsInfoByStakingToken[stakingToken];
        require(info.stakingRewards != address(0), 'StakingRewardsFactoryETH::notifyRewardAmount: not deployed');

        if (info.rewardAmount > 0) {
            uint rewardAmount = info.rewardAmount;
            info.rewardAmount = 0;

            require(
                IERC20(rewardsToken).transfer(info.stakingRewards, rewardAmount),
                'StakingRewardsFactoryETH::notifyRewardAmount: transfer failed'
            );
            StakingRewardsETH(info.stakingRewards).notifyRewardAmount(rewardAmount);
        }
    }

    
    // notify reward amount for an individual staking token.
    // this is a fallback in case the notifyRewardAmountsFrom costs too much gas to call for all contracts
    // This calls transferFrom, give allowance before to this smartcontract spend the rewards
    function notifyRewardAmountFrom(address stakingToken, address rewardsFrom) public {
        require(block.timestamp >= stakingRewardsGenesis, 'StakingRewardsFactoryETH::notifyRewardAmount: not ready');

        StakingRewardsInfo storage info = stakingRewardsInfoByStakingToken[stakingToken];
        require(info.stakingRewards != address(0), 'StakingRewardsFactoryETH::notifyRewardAmount: not deployed');

        if (info.rewardAmount > 0) {
            uint rewardAmount = info.rewardAmount;
            info.rewardAmount = 0;

            require(
                IERC20(rewardsToken).transferFrom(rewardsFrom, info.stakingRewards, rewardAmount),
                'StakingRewardsFactoryETH::notifyRewardAmountFrom: transfer failed'
            );
            StakingRewardsETH(info.stakingRewards).notifyRewardAmount(rewardAmount);
        }
    }

     /**
     * @notice Used in case of transfer non supported tokens
     */
    function release(address token) public onlyOwner{ 
        uint256 amount = IERC20(token).balanceOf(address(this));
        require(amount > 0, "send tokens back");
        IERC20(token).transfer(owner(), amount);
    }
}