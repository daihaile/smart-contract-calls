// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Receive {
    event Received(address caller, uint amount, string message);

    // Function to deposit Ether into this contract.
    // Call this function along with some Ether.
    // The balance of this contract will be automatically updated.
    function deposit() public payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
        // This function is called for all messages sent to
    // this contract, except plain Ether transfers
    // (there is no other function except the receive function).
    // Any call with non-empty calldata to this contract will execute
    // the fallback function (even if Ether is sent along with the call).
    fallback() external payable { 
        emit Received(msg.sender, msg.value, "Fallback was called");
    }

    // This function is called for plain Ether transfers, i.e.
    // for every call with empty calldata.
    receive() external payable {
        emit Received(msg.sender, msg.value, "Receive was called");
    }

    // Function to transfer Ether from this contract to address from input
    function transfer(address payable _to, uint _amount) public {
        // Note that "to" is declared as payable
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }
}
