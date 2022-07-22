pragma solidity ^0.8.11;
import"@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
contract TokenVendor is ERC20,Ownable{
    using SafeMath for uint;
    uint private Circulation;
    uint private rate = 40000000000000;
    mapping(address => uint)Bought;
    mapping(address => uint)Sold;
    event rateSet(address indexed _from,uint _value);
    event ownerChange(address indexed _from,address indexed _to);
    event tokensBought(address indexed _from,uint _value);
    event tokensSold(address indexed _from,uint _value);
    event withdraw(address indexed _from,address indexed _to,uint _value);
    

    constructor()
    ERC20("Stake inu","STK"){
        owner = msg.sender;
    }
    modifier OnlyOwner(){
        require(msg.sender == owner,"Unauthorized Access");
        _;
    }

    function ShowRate()external view returns(uint){
        return rate;
    }
    function SetRate(uint _rate)external OnlyOwner returns(bool success){
        require(_rate != 0,"Rate cannot be 0");
        rate = _rate;
        emit rateSet(msg.sender,_rate);
        return true;

    }
    function ShowOwner()external view returns(address){
        return owner;
    }

    function ChangeOwner(address _owner)external OnlyOwner returns(bool success){
        require(_owner != address(0),"New owner cannot be zero address");
        owner = _owner;
        emit ownerChange(msg.sender,_owner);
        return true;
    }


    function BuyTokens()external payable returns(bool success){
        require(rate != 0,"Rate has not been set");
        require(msg.value != 0,"You cannot send nothing");
        uint bought = msg.value.div(rate);
        uint fee = (bought.mul(10)).div(100);
        uint recieve = bought.sub(fee);
        bought = msg.value.div(rate);
        _mint(msg.sender,recieve);
        _mint(address(this),fee);
        Circulation = Circulation.add(bought);
        emit tokensBought(msg.sender,bought);
        return true;
    }

     function SellTokens(uint amount)external returns(bool success){
        uint sold = amount.mul(rate);
        uint fee = (amount.mul(10)).div(100);
        uint recieve = sold.sub(fee);
        uint UserBalance = balanceOf(msg.sender);
        require(amount != 0,"You cannot sell nothing");
        require(UserBalance >= amount,"Insufficient Amount Of Tokens");
        require(rate != 0,"Rate has not been set");
        require(BalanceVendor() >= sold,"Insufficient Cash");
        _burn(msg.sender,amount);
        _mint(address(this),fee);
        Circulation = Circulation.sub(amount);
        payable(msg.sender).transfer(recieve);
        emit tokensSold(msg.sender,amount);
        return true;
    }
  
    function TokeninCirculation()external view returns(uint){
        return Circulation;
    }

    function WithdrawETH(address payable _to,uint amount)external OnlyOwner payable returns(bool success){
        require(address(this).balance >= amount,"Insufficient Balance");
        _to.transfer(amount);
        emit withdraw(msg.sender,_to,amount);
        return true;
    }
    function TransferTokens(address _to,uint amount)external OnlyOwner returns(bool success){
        require(VendorTokenBalance() >= amount,"Insufficient amount");
        _mint(_to,amount);
        _burn(address(this),amount);
        return true;
    }

    function BalanceVendor()public view returns(uint){
        return address(this).balance;
    }
    function VendorTokenBalance()public view returns(uint){
        return balanceOf(address(this));
    }

    function TokenBalance()public view returns(uint){
        return balanceOf(msg.sender);
    }
    function ETHBalance()public view returns(uint){
        return (msg.sender).balance;
    }
    
}