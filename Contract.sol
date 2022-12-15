pragma solidity >=0.7.0 <0.9.0;


contract Init {
    event InitEvent(uint id, uint amount, uint timestamp, bool odd);
    event GambleInit(uint id, bytes32 color, uint amount, uint timestamp, bool odd, address sender);
    event PayFees(uint id, uint amount);
    event NewValue(uint id, address addr, uint newValue);
    event UpdateColorValue(bytes32 color);
    event Donate(address addr, uint amount);
    event Deposit(address addr, uint amount);
    event CallResponse(uint newValue1);

    uint public id;
    uint public lastTimestamp;
    uint public redCount;
    uint public blackCount;

    mapping(address => uint) public values;

    function donate() public payable returns (uint) {
        emit Donate(msg.sender, msg.value);
        return values[msg.sender];
    }

    function deposit() public payable returns (uint) {
        values[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
        return values[msg.sender];
    }

    function gamble(bool red, BCContract _bc) public payable{
        id++;
        lastTimestamp = block.timestamp;
        bool odd = true;
        if(lastTimestamp % 2 == 0) {
            odd = false;
        }
        bytes32 color = "blue";
        if(red) {
            color = "red";
        }
        uint value = values[msg.sender];
        emit InitEvent(id, value, lastTimestamp, odd);
        emit GambleInit(id, color, value, lastTimestamp, odd, msg.sender);

        (uint newValue) =  _bc.gamble{value: value}(id,color,odd,lastTimestamp);

        values[msg.sender] += newValue;
        emit CallResponse(newValue);
        emit NewValue(id, msg.sender, newValue);

        if(odd) {
            redCount++;
            emit PayFees(id, newValue);
            emit UpdateColorValue(color);
        }  else {
            blackCount++;
            emit UpdateColorValue(color);
            emit PayFees(id, newValue);
        }

    }

    fallback() external payable { }
    receive() external payable { }
}

contract BCContract {
    event Gamble(bytes32 color, bool odd, uint lastTimestamp, uint256 newValue);

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

    function gamble(uint _id, bytes32 color, bool odd, uint lastTimestamp) public payable returns (uint) {
        uint newValue;
        id = _id;
        if(odd && color == "red") {
            newValue = msg.value + msg.value / 2;
        } else {
            newValue = msg.value / 2;
        }
        uint fee = msg.value / 10;
        newValue -= fee;
        emit Gamble(color, odd, lastTimestamp, newValue);
        (bool sent,) = msg.sender.call{value: newValue}("");
        require(sent, "Failed to send Ether back");
        address _feeCollector = payable(feeAddress);
        (bool sent1,) = _feeCollector.call{value: fee}("");
        require(sent1, "Failed to send fee");
        return newValue;
    }

}

contract EndContract{

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