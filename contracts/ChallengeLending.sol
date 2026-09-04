// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface TokenInterface {
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
    function mint(address account, uint256 amount) external;
    function transfer(address to, uint256 value) external returns (bool);    
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


contract ChallengeLending is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    uint256 public constant MAX_LTV = 75; // 75%
    uint256 public constant LIQUI_THRESHOLD = 78; // 78%
    uint256 public constant LIQUI_PENALTY = 5; // 5%

    TokenInterface public vETH;
    TokenInterface public vUSD;
    uint256 public vETHPrice = 200000; // 2000.00 vUSD
    uint256 public start_vETH = 1500;    //15 vUSD
    uint256 public start_vUSD = 10000;
    uint256 public start_Collateral = 10;
    uint256 public start_Borrow = 7000;

    address[] public users;
    mapping(address => bool) public isUser;
    mapping(address => uint256) public userCollateral;
    mapping(address => uint256) public userDebt;
    mapping(address => uint256) public userHF;

    constructor(address _vETHaddress, address _vUSDaddress){
    	_grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    	_grantRole(ADMIN_ROLE, msg.sender);

        vETH = TokenInterface(_vETHaddress);
        vUSD = TokenInterface(_vUSDaddress);
    }
    
    event PriceUpdate(uint256 oldPrice, uint256 newPrice);

    function join() external {
        users.push(msg.sender);
        isUser[msg.sender] = true;
        vETH.mint(msg.sender, (start_vETH-start_Collateral));
        vUSD.mint(msg.sender, (start_vUSD-start_Borrow));
        vETH.mint(address(this), start_Collateral);
        userCollateral[msg.sender] += start_Collateral;
        vUSD.mint(address(this), start_Borrow);
        userDebt[msg.sender] += start_Borrow;
        calcHF(msg.sender);
    }

    /// @notice vETH token as collateral
    function deposit(uint256 amount) external  {
        require(vETH.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        userCollateral[msg.sender] += amount;
    }

    /// @notice Borrow vUSD against collateral
    function borrow(uint256 amount) external {
        require(userCollateral[msg.sender] >= minCollateral(amount), "Insufficient collateral");
        require(vUSD.transfer(msg.sender, amount), "Transfer failed");
        userDebt[msg.sender] += amount;
    }

    /// @notice Repay loan
    function repay(uint256 amount) external {
        require(userDebt[msg.sender] >= amount, "Too much repayment");
        require(vUSD.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        userDebt[msg.sender] -= amount;
    }

    /// @notice Withdraw Collateral (only if loan is repaid)
    function withdrawCollateral(uint256 amount) external {
        require(userDebt[msg.sender] == 0, "Pay all debt first");
        require(userCollateral[msg.sender] >= amount, "Not enough collateral");
        
        require(vETH.transfer(msg.sender, amount), "Transfer failed");
        userCollateral[msg.sender] -= amount;
    }

    /// @notice Calculate the minimum collateral to borrow the amount
    function minCollateral(uint256 amount) public view returns (uint256) {
        
        uint256 requiredCollateral; //Calculate it
        return requiredCollateral;
    }

    function updatevETHPrice(uint256 price) external onlyRole(ADMIN_ROLE) {
        emit PriceUpdate(vETHPrice, price);
        vETHPrice = price;
    }

    function calcHF(address user) public returns (uint256) {
        userHF[user] = userCollateral[user] * LIQUI_THRESHOLD / userDebt[user];
        return userHF[user];
    }

    function checkAllHF() public onlyRole(ADMIN_ROLE) {
        //loop to all users        
        // calcHF
        //if (userHF[user] <= 1) {
            //liquidateUser(address user)
        //}        
    }

    function liquidateUser(address user) internal {
        // calculate the amount to be in MAX_LTV
        // get amount plus LIQUI_PENALTY
        // pay part of debt 
    }


    // Admin: withdraw stuck tokens
    function rescueTokens(address token, uint256 amount) external onlyRole(ADMIN_ROLE) {
        TokenInterface(token).transfer(msg.sender, amount);
    }

}
