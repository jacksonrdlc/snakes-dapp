// contracts/Box.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./access-control/Auth.sol";

contract Box{
    uint256 private _value;
    Auth private _auth;

    event ValueChanged(uint256 indexed value);

    constructor() {
        _auth = new Auth(msg.sender);
    }

    function store(uint256 value) public {
        require(_auth.isAdministrator(msg.sender), "Not authorized");

        value = _value;
        emit ValueChanged(_value);
    }

    function retrieve() public view returns(uint256){
        return _value;
    }
}