// SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.18;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title DSCEngine
 * @author Ryan Sumithra
 * *The system is designed to be as minimal as possible, and have the tokens maintain a 1 token == $1 peg
 * This stablecoin has the properties:
 * - Exogeneous Collateral
 * - Dollar Pegged
 * -- Algorithmically Stable
 * 
 * It is similar to DAI if DAI had no governance, no fees, and was only backed by WETH & WBTC
 * 
 * Our DSC System should always be "overcollateralized". At no point, should the value of all
collateral <= the value of all the DSC
 * @notice This contract is the core of the DSC system. It handles all the logic for mining and reddeming DSC,
 as well as depositing & withddrawing collateral.
 * @notice This contract is very loosely based on the MakerDAO DSS (DAI Stablecoin System)
 */

contract DSCEngine is ReentrancyGuard {
    /* Errors */
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error DSCEngine__NotAllowedToken();
    error DSCEngine__TransferFailed();

    /* State Variables */    
    mapping(address token => address priceFeeds) private s_priceFeeds; // tokenToPriceFeed
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;

    DecentralizedStableCoin private immutable i_dsc;

    /* Events */
    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);

    /* Modifiers */
    modifier moreThanZero(uint256 amount){
        if(amount == 0){
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token){
        if(s_priceFeeds[token] == address(0)){
            revert DSCEngine__NotAllowedToken();
        }
        _;
    }

    /* Functions */

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress){
        // USD Price Feeds
        if(tokenAddresses.length != priceFeedAddresses.length){
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }

        for(uint256 i = 0;i < tokenAddresses.length;i++){
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }
        i_dsc = DecentralizedStableCoin(dscAddress);

    }

    /* External Functions */    
    function depositCollateralAndMintDsc() external{}


    /**
     * @notice Follows CEI
     * @param tokenCollateralAddress The address of the token to deposit as collateral
     * @param amountCollateral The amount of collateral to deposit
     */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral) external moreThanZero(amountCollateral) isAllowedToken(tokenCollateralAddress) nonReentrant{
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);

        if(!success){
            revert DSCEngine__TransferFailed();
        }

    }

    function redeemCollateralForDsc() external{}

    function redeemCollateral() external{}

    /**
     * @notice Follows CEI
     * @param amountDscToMint The amount of Decentralized Stablecoin to mint
     * @notice they must have more collateral value than the minimum threshold
     */

    function mintDsc(uint256 amountDscToMint) external moreThanZero(amountDscToMint) nonReentrant{}

    function burnDsc() external{}

    function liquidate() external{}

    function gethealthFactor() external view{}
}