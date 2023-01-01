pragma solidity >=0.7.0 <0.9.0;


contract Gamble {
    event GambleStart(uint id,address sender);
    event GambleRed(uint id, bool odd, address sender, uint value);
    event GambleBlack(uint id, bool odd, address sender, uint value);
    event NewBalance(uint id, address addr, uint newValue, uint balance);
    event ReturnValue(uint id, uint value);
    event CollectWins(uint id, uint value);

    uint public id;
    uint public lastTimestamp;
    address payable public calculateContract;

    mapping(address => uint) public values;

    function deposit() public payable returns (uint) {
        values[msg.sender] += msg.value;
        return values[msg.sender];
    }

    function gambleRed() public payable{
        id++;
        emit GambleStart(id,msg.sender);
        lastTimestamp = block.timestamp;
        bool odd = true;
        if(lastTimestamp % 2 == 0) {
            odd = false;
        }
        emit GambleRed(id, odd, msg.sender, msg.value);
        callCalculate(true, odd, lastTimestamp);
    }

    function gambleBlack() public payable{
        id++;
        emit GambleStart(id,msg.sender);
        lastTimestamp = block.timestamp;
        bool odd = true;
        if(lastTimestamp % 2 == 0) {
            odd = false;
        }
        emit GambleBlack(id, odd, msg.sender, msg.value);
        callCalculate(false, odd, lastTimestamp);
    }

    function setCalculateContract(address _addr) public returns (address){
        calculateContract = payable(_addr);
        return calculateContract;
    }

    function callCalculate(bool isRed, bool odd, uint timestamp) private{
        Calculate calc = Calculate(calculateContract);
        (uint newValue) = calc.calculate{value: msg.value}(id,isRed,odd, timestamp);
        values[msg.sender] += newValue;        
        if(odd) {
            emit CollectWins(id, newValue);
            emit NewBalance(id, msg.sender, newValue, values[msg.sender]);
        }  else {
            emit NewBalance(id, msg.sender, newValue, values[msg.sender]);
            emit CollectWins(id, newValue);
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

    function calculate(uint _id, bool isRed, bool odd, uint timestamp) public payable returns (uint) {
        uint newValue;
        id = _id;
        if(odd && isRed) {
            newValue = msg.value + msg.value / 2;
        } else {
            newValue = msg.value / 2;
        }
        uint fee = msg.value / 10;
        newValue -= fee;
        emit CalculateGamble(_id, isRed, odd, timestamp, newValue);
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