// SPDX-License-Identifier: MIT

// Web: https://tradefi.bot/
//⁠ ⁠Whitepaper: https://docs.tradefi.bot/whitepaper
// Twitter: https://x.com/Tradefibot
// Telegram: https://t.me/TradefibotChat
// ⁠Instagram: https://www.instagram.com/tradefibot
// ⁠Youtube Channel: https://www.youtube.com/@Tradefibot

pragma solidity 0.8.20;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {_approve(owner, spender, currentAllowance - subtractedValue);}
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked { _balances[from] = fromBalance - amount;}
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner, address spender,uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

contract TDFI is ERC20 {
    uint256 public constant maxSupply = 150000000000000000000000000;
    // Project Wallets
    address public constant seedPresaleWalletA = address(0xB3219929716d152025CBF44ae6251eFf1522c87b);
    uint256 public constant seedPresalePercentage = 300;

    address public constant privatePresaleWalletB = address(0x680CE202cb9a48791d069cA1D374c21D53Cd997E);
    uint256 public constant privatePresalePercentageB = 170;

    address public constant privatePresaleWalletC = address(0xce8F9545548156e29e259e3a51FF3C20413466F4);
    uint256 public constant privatePresalePercentageC = 1350;

    address public constant publicPresaleWallet = address(0x647cF37D0176E4De0422aC1e74802e645e00FD04);
    uint256 public constant publicPresalePercentage = 38180;

    address public constant liquidityWallet = address(0xAeBFDC682d88F1Aa79Deee769d58921381333D89);
    uint256 public constant liquidityPercentage = 40000;

    address public constant developmentWallet = address(0xe06ded0573864ef4Ee647Fa9A96b42397Fb871ee);
    uint256 public constant developmentPercentage = 6000;

    address public constant marketingWallet = address(0xE6B72b45217522538890FC1Ae9A0888bf40281D6);
    uint256 public constant marketingPercentage = 6000;

    address public constant treasuryWallet = address(0x92b4eFAf6A42E35a5A7Dbaf64fA58055803CCE1c);
    uint256 public constant treasuryPercentage = 4000;

    address public constant growthWallet = address(0x80f574A044F5D77ba94c29C04941288B182f88DF);
    uint256 public constant growthPercentage = 4000;

    address public constant dividendsWallet = address(0x441E1E6AD328d43C66e5D3d79D1959D2bc28185f);

    address public constant burnWallet = address(0x000000000000000000000000000000000000dEaD);

    address public daoWallet = address(0x01BEED82101Dacf3a8D1f57d000878B20CdE901B); //multi-signature wallet

    IUniswapV2Router02 private uniswapV2Router;
    address public immutable uniswapV2Pair;

    uint16 public constant sellTax = 5;

    mapping(address => bool) public automatedMarketMakerPairs;

    constructor()
        ERC20("Tradefi.bot Token", "TDFI")
    {
        // Uniswap Router
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
        // Mint the initial supply
        _initialSupply();
    }

    modifier onlyDAO() {
        require(msg.sender == daoWallet, "Only the DAO can perform this action");
        _;
    }

    function updateDao(address _newDao) public onlyDAO {
        require(_newDao != address(0), "New DAO address cannot be zero");
        emit DaoWalletUpdated(daoWallet, _newDao);
        daoWallet = _newDao;
    }

    // Initial Supply
    function _initialSupply() private {
        _mint(seedPresaleWalletA, (maxSupply * seedPresalePercentage) /  100000);
        _mint(privatePresaleWalletB, (maxSupply * privatePresalePercentageB) / 100000);
        _mint(privatePresaleWalletC, (maxSupply * privatePresalePercentageC) / 100000);

        _mint(publicPresaleWallet, (maxSupply * publicPresalePercentage) / 100000);
        _mint(liquidityWallet, (maxSupply * liquidityPercentage) / 100000);
        _mint(marketingWallet, (maxSupply * marketingPercentage) / 100000);
        _mint(developmentWallet, (maxSupply * developmentPercentage) / 100000);
        _mint(treasuryWallet, (maxSupply * treasuryPercentage) / 100000);
        _mint(growthWallet, (maxSupply * growthPercentage) / 100000);
    }

    // events
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event DaoWalletUpdated(address indexed oldDao, address indexed newDao);

    // Manage AMM pairs by DAO
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyDAO {
        require(pair != uniswapV2Pair, "The Uniswap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    // Override transfer to apply sell tax for DEX trades
    function _transfer(address from, address to, uint256 amount) internal override {
        if (automatedMarketMakerPairs[to]) {
            // Sell
            uint256 fee = (amount * sellTax) / 100;
            uint256 treasuryAmount = (fee * 25) / 100;
            uint256 burnAmount = (fee * 25) / 100;
            uint256 dividendsAmount = fee - treasuryAmount - burnAmount;
            uint256 tAmount = amount - fee;
            // Distribute tax
            super._transfer(from, treasuryWallet, treasuryAmount);
            emit Transfer(from, treasuryWallet, treasuryAmount);

            super._transfer(from, burnWallet, burnAmount);
            emit Transfer(from, burnWallet, burnAmount);

            super._transfer(from, dividendsWallet, dividendsAmount);
            emit Transfer(from, dividendsWallet, dividendsAmount);

            super._transfer(from, to, tAmount);
            emit Transfer(from, to, tAmount);
        } else {
            // Standard transfer for non-DEX trades
            super._transfer(from, to, amount);
            emit Transfer(from, to, amount);
        }
    }
}
