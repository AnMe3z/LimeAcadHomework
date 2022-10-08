// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.12 <0.9.0;

import "./2_Owner.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Library is Owner {

    struct Book {
        uint id;
        uint copies;
    }

    Book[] public books;

    mapping (address => Book[]) userToBooks;
    // mapping (address => uint) userToBorrowedBooksCount;
    mapping(uint => address[]) bookIdToAllBorrowers;

    event ShowBook(uint id, uint copies);
    event ShowAddress(address addr);

    //admin
    function addNewBook(uint _id, uint _copies) public isOwner() {
        books.push(Book(_id, _copies));
    }

    //user
    function showAvailableBooks() public {
        for(uint i = 0; i < books.length; i++){
            emit ShowBook(books[i].id, books[i].copies);
        }
    }

    function findBookById(Book[] memory _books, uint _id) private pure returns(Book memory) {
        Book memory book;
        for(uint i = 0; i < _books.length; i++){
            if(_books[i].id == _id){
                book = _books[i];
                return book;
            }
        }
        return book;
    }

    function checkIfUserHasBook(address _user, uint _id) private view returns(bool) {
        for(uint i = 0; i < userToBooks[_user].length; i++){
            if(userToBooks[_user][i].id == _id){
                return true;
            }
        }
        return false;
    }

    function removeBook(Book[] storage _books, uint _id) private {
        Book storage book;
        for(uint i = 0; i < _books.length; i++){
            if(_books[i].id == _id){
                book = _books[i];
            }
        }
        
        for(uint i = 0; i < _books.length; i++){
            if(_books[i].id == _id){
                _books[i] = _books[_books.length - 1];
                _books.pop();
            }
        }
    }

    function borrowBook(uint _id) public {
        address user = msg.sender;
        Book memory book = findBookById(books, _id);

        require(!checkIfUserHasBook(user, _id));
        require(book.copies > 0);

        userToBooks[user].push(book);

        bookIdToAllBorrowers[book.id].push(user);

        book.copies--;
    }

    function returnBook(uint _id) public {
        address user = msg.sender;

        require(checkIfUserHasBook(user, _id));

        Book memory book = findBookById(userToBooks[user], _id);
        
        removeBook(userToBooks[user], _id);
        book.copies++;
    }

    function seeAllAddressesBorrowed(uint _id) public {
        for(uint i = 0; i < bookIdToAllBorrowers[_id].length; i++){
            emit ShowAddress(bookIdToAllBorrowers[_id][i]); 
        }
    }

}