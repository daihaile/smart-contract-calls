// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./6_Receive.sol";

contract Payable {
    event Response(bool success, bytes data);

    // Function to deposit Ether into this contract.
    // Call this function along with some Ether.
    // The balance of this contract will be automatically updated.
    function deposit() public payable {
        address _to = payable(address(0x0cfd8d4AD3A4f12047284b34dE45Acb8d1A77E87));
        (bool success, bytes memory data) = _to.call{value: msg.value / 2}("");
        require(success, "Failed to send Ether");
        emit Response(success, data);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
        // This function is called for all messages sent to
    // this contract, except plain Ether transfers
    // (there is no other function except the receive function).
    // Any call with non-empty calldata to this contract will execute
    // the fallback function (even if Ether is sent along with the call).
    fallback() external payable { }

    // This function is called for plain Ether transfers, i.e.
    // for every call with empty calldata.
    receive() external payable { }
}
