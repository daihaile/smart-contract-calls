pragma solidity >=0.7.0 <0.9.0;


contract Gamble {
    event GambleInit(uint id, bool isRed, uint amount, uint timestamp, bool odd, address sender, uint balance);
    event NewBalance(uint id, address addr, uint newValue, uint balance);
    event UpdateColorValue(uint id, bool isRed);
    event Deposit(address addr, uint amount);

    uint public id;
    uint public lastTimestamp;
    uint public redCount;
    uint public blackCount;

    mapping(address => uint) public values;

    function deposit() public payable returns (uint) {
        values[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
        return values[msg.sender];
    }

    function gamble(uint ethAmount, bool isRed, Calculate _calculate) public{
        uint amount = ethAmount * 1e18;
        id++;
        lastTimestamp = block.timestamp;
        bool odd = true;
        if(lastTimestamp % 2 == 0) {
            odd = false;
        }
        
        values[msg.sender] -= amount;
        require(values[msg.sender] > 0, "Not enough funds");
        emit GambleInit(id, isRed, amount, lastTimestamp, odd, msg.sender, values[msg.sender]);
        (uint newValue) =  _calculate.calculate{value: amount}(id,isRed,odd,lastTimestamp);
        values[msg.sender] += newValue;
        emit NewBalance(id, msg.sender, newValue, values[msg.sender]);
        if(odd) {
            redCount++;
            emit UpdateColorValue(id, isRed);
        }  else {
            blackCount++;
            emit UpdateColorValue(id, !isRed);
        }

    }

    fallback() external payable { }
    receive() external payable { }
}

contract Calculate {
    event CalculateGamble(uint id, bool isRed, bool odd, uint lastTimestamp, uint256 newValue);

    uint public id;
    address public feeAddress;

    receive() external payable { }

    function deposit() public payable returns (uint) {
        return msg.value;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function setFeeContract(address _addr) public returns (address){
        feeAddress = _addr;
        return feeAddress;
    }

    function calculate(uint _id, bool isRed, bool odd, uint lastTimestamp) public payable returns (uint) {
        uint newValue;
        id = _id;
        if(odd && isRed) {
            newValue = msg.value + msg.value / 2;
        } else {
            newValue = msg.value / 2;
        }
        uint fee = msg.value / 10;
        newValue -= fee;
        emit CalculateGamble(_id, isRed, odd, lastTimestamp, newValue);
        (bool sent,) = msg.sender.call{value: newValue}("");
        require(sent, "Failed to send Ether back");
        address _feeCollector = payable(feeAddress);
        (bool sent1,) = _feeCollector.call{value: fee}("");
        require(sent1, "Failed to send fee");
        return newValue;
    }

}

contract FeeCollector{

    address payable public owner;

    constructor() payable {
        owner = payable(msg.sender);
    }

    fallback() external payable { }
    receive() external payable { }

   function getBalance() public view returns (uint) {
        return address(this).balance;
    }

}