// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TokensVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme.
 */
contract Vesting is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event TokensReleased(uint256 amount);
    event TokensVestingRevoked(address receiver, uint256 amount);

    // beneficiary of tokens after they are released
    address private _mentor;
    address private _advisor;

    // Durations and timestamps are expressed in UNIX time, the same units as block.timestamp.
    uint256 private _start;
    uint256 private _finish;
    uint256 private _duration;
    uint256 private _releasesCount;
    uint256 public _releasedForMentor;
    uint256 public _releasedForAdvisor;
    uint256 private _cliff;

    uint256 public _released;

    address private _revoker;
    bool private _revocable;
    bool private _revoked;

    IERC20 private _token;

    constructor(
        address token,
        address advisor,
        address mentor,
        uint256 start,
        bool revocable,
        address revoker
    ) {
        require(
            advisor != address(0),
            "TokensVesting: advisor is the zero address!"
        );
        require(
            mentor != address(0),
            "TokensVesting: mentor is the zero address!"
        );
        require(
            token != address(0),
            "TokensVesting: token is the zero address!"
        );
        require(
            revoker != address(0),
            "TokensVesting: revoker is the zero address!"
        );

        _token = IERC20(token);
        _advisor = advisor;
        _mentor = mentor;

        _revocable = revocable;
        _duration = 86400; //seconds in a day
        _cliff = 5184000; //2 months cliff
        _releasesCount = 669; //days in 22 months
        _start = start;
        _finish = _start.add(_releasesCount.mul(_duration)) + _cliff;

        _revoker = revoker;
    }

    // -----------------------------------------------------------------------
    // GETTERS
    // -----------------------------------------------------------------------

    /**
     * @return the beneficiary of the tokens.
     */
    function Advisor() public view returns (address) {
        return _advisor;
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function Mentor() public view returns (address) {
        return _mentor;
    }

    /**
     * @return the start time of the token vesting.
     */
    function Start() public view returns (uint256) {
        return _start;
    }

    /**
     * @return the finish time of the token vesting.
     */
    function finish() public view returns (uint256) {
        return _finish;
    }

    /**
     * @return the duration of the token vesting.
     */
    function Duration() public view returns (uint256) {
        return _duration;
    }

    /**
     * @return the duration of the token vesting.
     */
    function Cliff() public view returns (uint256) {
        return _cliff;
    }

    /**
     * @return true if the vesting is revocable.
     */
    function Revocable() public view returns (bool) {
        return _revocable;
    }

    /**
     * @return the amount of the token released.
     */
    function Released() public view returns (uint256) {
        return _releasedForMentor + _releasedForAdvisor;
    }

    /**
     * @return true if the token is revoked.
     */
    function revoked() public view returns (bool) {
        return _revoked;
    }

    /**
     * @return address, who allowed to revoke.
     */
    function Revoker() public view returns (address) {
        return _revoker;
    }

    // -----------------------------------------------------------------------
    // SETTERS
    // -----------------------------------------------------------------------

    /**
     * @notice Transfers vested tokens to beneficiary.
     */
    function release() public onlyOwner {
        uint256 unreleased = _releasableAmount();
        uint256 unreleasedForAdvisor = (unreleased.mul(5)).div(12);
        uint256 unreleasedForMentor = (unreleased.mul(7)).div(12);
        require(unreleasedForAdvisor > 0, "release: No tokens are due!");
        require(unreleasedForMentor > 0, "release: No tokens are due!");
        _released = _released.add(unreleased);

        _releasedForAdvisor = _releasedForAdvisor.add(unreleasedForAdvisor);
        _releasedForMentor = _releasedForMentor.add(unreleasedForMentor);

        _token.safeTransfer(_advisor, unreleasedForAdvisor);
        _token.safeTransfer(_mentor, unreleasedForMentor);

        emit TokensReleased(unreleasedForAdvisor);
        emit TokensReleased(unreleasedForMentor);
    }

    /**
     * @notice Allows the owner to revoke the vesting. Tokens already vested
     * remain in the contract, the rest are returned to the owner.
     * @param receiver Address who should receive tokens
     */
    function revoke(address receiver) public {
        require(msg.sender == _revoker, "revoke: unauthorized sender!");
        require(_revocable, "revoke: cannot revoke!");
        require(!_revoked, "revoke: token already revoked!");

        uint256 balance = _token.balanceOf(address(this));
        uint256 unreleased = _releasedForAdvisor.add(_releasedForMentor);
        uint256 refund = balance.sub(unreleased);

        _revoked = true;
        _token.safeTransfer(receiver, refund);

        emit TokensVestingRevoked(receiver, refund);
    }

    // -----------------------------------------------------------------------
    // INTERNAL
    // -----------------------------------------------------------------------

    /**
     * @dev Calculates the amount that has already vested but hasn't been released yet.
     */
    function _releasableAmount() private view returns (uint256) {
        return _vestedAmount().sub(_released);
    }

    /**
     * @dev Calculates the amount that has already vested.
     */
    function _vestedAmount() private view returns (uint256) {
        uint256 currentBalance = _token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(_released);
        require(block.timestamp > (_start + _cliff), "release: No tokens are due!");
        

        if (block.timestamp < _start) {
            return 0;
        } else if (block.timestamp >= _finish || _revoked) {
            return totalBalance;
        } else {
            uint256 timeLeftAfterStart = (block.timestamp.sub(_start)).sub(
                _cliff
            );
            uint256 availableReleases = timeLeftAfterStart.div(_duration);
            uint256 tokensPerRelease = totalBalance.div(_releasesCount);

            return availableReleases.mul(tokensPerRelease);
        }
    }
}
