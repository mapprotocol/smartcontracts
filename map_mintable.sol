//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract MAP {
    // --- Auth ---
    mapping (address => uint256) public wards;
    function rely(address account) external auth { wards[account] = 1; }
    function deny(address account) external auth { wards[account] = 0; }
    
    modifier auth {
        require(wards[msg.sender] == 1, "not-authorized");
        _;
    }

    // --- ERC20 Data ---
    string  public constant name     = "MAP Protocol";
    string  public constant symbol   = "MAP";
    string  public constant version  = "1";
    uint8   public constant decimals = 18;
    uint256 public totalSupply;

    mapping (address => uint256)                      public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Approval(address indexed from, address indexed to, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    constructor() {
        wards[msg.sender] = 1;
    }

    // --- Math ---
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    // --- Token ---
    function transfer(address to, uint256 amount) external returns (bool) {
        return transferFrom(msg.sender, to, amount);
    }
    
    function transferFrom(address from, address to, uint256 amount)public returns (bool){
        require(balanceOf[from] >= amount, "insufficient-balance");
        if (from != msg.sender && allowance[from][msg.sender] != type(uint256).max) {
            require(allowance[from][msg.sender] >= amount, "insufficient-allowance");
            allowance[from][msg.sender] = sub(allowance[from][msg.sender], amount);
        }
        balanceOf[from] = sub(balanceOf[from], amount);
        balanceOf[to] = add(balanceOf[to], amount);
        emit Transfer(from, to, amount);
        return true;
    }
    
    function mint(address account, uint256 amount) external auth {
        balanceOf[account] = add(balanceOf[account], amount);
        totalSupply    = add(totalSupply, amount);
        emit Transfer(address(0), account, amount);
    }
    
    function burn(uint256 amount) external {
        burnFrom(msg.sender, amount);
    }
    
    function burnFrom(address account, uint256 amount) public {
        require(balanceOf[account] >= amount, "insufficient-balance");
        if (account != msg.sender && allowance[account][msg.sender] != type(uint256).max) {
            require(allowance[account][msg.sender] >= amount, "insufficient-allowance");
            allowance[account][msg.sender] = sub(allowance[account][msg.sender], amount);
        }
        balanceOf[account] = sub(balanceOf[account], amount);
        totalSupply    = sub(totalSupply, amount);
        emit Transfer(account, address(0), amount);
    }
    
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(spender,amount);
        return true;
    }
    
    function increaseApproval(address spender, uint256 addedValue) external
    returns (bool success) {
        uint256 newValue = add(allowance[msg.sender][spender], addedValue);
        _approve(spender,newValue);
        return true;
    }

    function decreaseApproval(address spender, uint256 subtractedValue) external
    returns (bool success) {
        uint256 newValue = 0;
        if (subtractedValue < allowance[msg.sender][spender]) {
            newValue = sub(allowance[msg.sender][spender], subtractedValue);
        }
        _approve(spender,newValue);
        return true;
    }
    
    function _approve(address spender, uint256 amount) internal {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    } 
    
}
