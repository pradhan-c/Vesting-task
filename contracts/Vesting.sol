// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @title TokensVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme.
 */
contract Vesting is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // address of the ERC20 token
    IERC20 private _token;
    //the Three roles advisor,partnership and mentor
    enum Roles {
        advisor,
        partnership,
        mentor
    }
    //Vesting
    struct VestingDetails {
        Roles role;
        uint256 startTime;
        uint256 cliff;
        uint256 totalAmount;
        uint256 vestedAmount;
        uint256 duration;
        uint256 finish;
        uint256 releaseCount;
        bool revoked;
    }

    mapping(address => VestingDetails) public VestingSchedule;

    event TokensVestingRevoked(address receiver, uint256 amount);
    event TokensReleased(uint256 amount);

    uint256 public advisorsTge = 5;
    uint256 public mentorsTge = 7;

    uint256 public advisor;
    uint256 public mentor;

    uint256 public scheduledAdvisor = 0;
    uint256 public scheduledMentor = 0;

    constructor(address token_, uint256 totalSupply) {
        require(token_ != address(0x0));
        _token = IERC20(token_);
        CalculateTGE(totalSupply);
    }

    /**
     * @dev Returns the address of the ERC20 token managed by the vesting contract.
     */
    function getToken() external view returns (address) {
        return address(_token);
    }

    function createVestingSchedule(
        address beneficiary,
        Roles role,
        uint256 startTime,
        uint256 cliff,
        uint256 totalAmount,
        uint256 duration,
        uint256 releaseCount,
        bool revoked
    ) public onlyOwner {
        require(
            VestingSchedule[beneficiary].startTime == 0,
            "Beneficiary already have a vesting Schedule"
        );
        if (role == Roles.advisor) {
            require(
                scheduledAdvisor + totalAmount < advisor,
                "not enough advisors token"
            );
            scheduledAdvisor += totalAmount;
        } else if (role == Roles.mentor) {
            require(
                scheduledMentor + totalAmount < mentor,
                "not enough mentors token"
            );
            scheduledMentor += totalAmount;
        }

        uint256 finish = startTime.add(releaseCount.mul(duration)).add(cliff);

        VestingSchedule[beneficiary] = VestingDetails(
            role,
            startTime,
            cliff,
            totalAmount,
            0,
            duration,
            finish,
            releaseCount,
            revoked
        );
    }

    /**
     * @notice Transfers vested tokens to beneficiary.
     */
    function release(address _raddress) public onlyOwner {
        uint256 unreleased = _releasableAmount(_raddress);
        uint256 alreadyreleased = VestingSchedule[_raddress].vestedAmount;

        require(unreleased > 0, "release: No tokens are due!");

        VestingSchedule[_raddress].vestedAmount = alreadyreleased.add(
            unreleased
        );

        _token.safeTransfer(_raddress, unreleased);
        emit TokensReleased(unreleased);
    }

    function Revoke(address receiver, address revoke) public onlyOwner {
        uint256 refund = (VestingSchedule[revoke].totalAmount).sub(
            VestingSchedule[revoke].vestedAmount
        );

        VestingSchedule[revoke].revoked = true;
        _token.safeTransfer(receiver, refund);

        emit TokensVestingRevoked(receiver, refund);
    }

    function CalculateTGE(uint256 _tsupply) private {
        advisor = _tsupply.mul(advisorsTge).div(100);
        mentor = _tsupply.mul(mentorsTge).div(100);
    }

    /**
     * @dev Calculates the amount that has already vested but hasn't been released yet.
     */
    function _releasableAmount(address user) private view returns (uint256) {
        return _uvestedAmount(user).sub(VestingSchedule[user].vestedAmount);
    }

    /**
     * @dev Calculates the amount that has already vested.
     */
    function _uvestedAmount(address _user) private view returns (uint256) {
        require(
            block.timestamp >
                VestingSchedule[_user].startTime + VestingSchedule[_user].cliff,
            "no token in cliff period"
        );

        if (block.timestamp < VestingSchedule[_user].startTime) {
            return 0;
        } else if (block.timestamp >= VestingSchedule[_user].finish) {
            return VestingSchedule[_user].totalAmount;
        } else {
            uint256 timeLeftAfterStart = (
                block.timestamp.sub(VestingSchedule[_user].startTime)
            ).sub(VestingSchedule[_user].cliff);
            uint256 availableReleases = timeLeftAfterStart.div(
                VestingSchedule[_user].duration
            );
            uint256 tokensPerRelease = VestingSchedule[_user].totalAmount.div(
                VestingSchedule[_user].releaseCount
            );

            return availableReleases.mul(tokensPerRelease);
        }
    }
}
