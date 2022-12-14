pragma solidity >=0.7.0 <0.9.0;


contract Init {
    event InitEvent(uint id, address _addr, uint amount, uint timestamp, bool odd);
    event GambleInit(uint id, bytes32 color, uint amount, uint timestamp, bool odd, address sender);
    event PayFees(uint id, uint amount);
    event NewValue(uint id, address addr, uint newValue);
    event UpdateColorValue(bytes32 color);
    event Donate(address addr, uint amount);
    event Deposit(address addr, uint amount);

    uint public id;
    uint public lastTimestamp;
    uint public redCount;
    uint public blackCount;
    address public bcContract;

    mapping(address => uint) public values;

    function setBCContract(address _addr) public {
        bcContract = _addr;
    }

    function donate() public payable returns (uint) {
        emit Donate(msg.sender, msg.value);
        return values[msg.sender];
    }

    function deposit() public payable returns (uint) {
        values[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
        return values[msg.sender];
    }

    function gamble(bool red) public {
        require(bcContract != 0x0000000000000000000000000000000000000000);
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
        values[msg.sender] = 0;
        emit InitEvent(id, bcContract, value, lastTimestamp, odd);
        emit GambleInit(id, color, value, lastTimestamp, odd, msg.sender);

        uint newValue = callNextFunction(id, color, odd, value);
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

    function callNextFunction(uint _id, bytes32 color, bool odd, uint256 value) private returns(uint) {
        require(bcContract != 0x0000000000000000000000000000000000000000);
        BCContract bc = BCContract(bcContract);
        uint newValue = bc.gamble{value: values[msg.sender]}(_id,color,odd,lastTimestamp,value);
        values[msg.sender] += newValue;
        emit NewValue(id, msg.sender, newValue);
        return newValue;
    }

    fallback() external payable { }
    receive() external payable { }
}

contract BCContract {
    event Gamble(bytes32 color, bool odd, uint lastTimestamp, uint256 newValue);
    uint id;

    function gamble(uint _id, bytes32 color, bool odd, uint lastTimestamp, uint value) public payable returns (uint) {
        uint newValue;
        id = _id;
        if(odd && color == "red") {
            newValue = value * 2;
        } else {
            newValue = value / 2;
        }
        emit Gamble(color, odd, lastTimestamp, newValue);
        return newValue;
    }

}

