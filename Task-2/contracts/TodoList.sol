// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract TodoList {
    
    struct Todo {
        string text; //Describe the todo. Ex. "Finish the task2"
        bool completed; //Show the todo is completed or not.
    }

    Todo[] public todos; // Todos array.

    /*
    @dev Events necessary to inform front end of the application about events/functions states 
         at the backend/smart contract.
    */
    event TodoCreated(string text); // Occurs when created a todo

    event TodoUpdated(uint256 index, string text); // Occurs when updated a todo

    event TodoCompleted(uint256 index, string text); // Occurs when completed a todo

    /*
    @dev Creates a Todo and adds to "todos" array.
    @param _text - Todo text that given by user.
    */
    function create(string calldata _text) external {
        todos.push(Todo({text: _text, completed: false}));

        emit TodoCreated(_text); // Emits the event, means, inform the user about an event occured.
    }

    /*
    @dev Updates the exist Todo.
    @param _index - Index of the Todo that wanted to change.
    @param _newText - New text that will replaced with old Todo.
    */
    function updateText(uint256 _index, string calldata _newText) external {
        todos[_index].text = _newText;

        emit TodoUpdated(_index, _newText);
    }

    /*
    @dev Gets the todo by index
    @param _index - Todo's index wanted to get.
    @return Todo text and if completed or not.
    */
    function get(uint256 _index) external view returns (string memory, bool) {
        Todo memory todo = todos[_index];

        return (todo.text, todo.completed);
    }

    /*
    @dev Completes the toggle,
    @param _index - Index of the Todo that wanted to complete.
    */
    function toggleCompleted(uint256 _index) external {
        todos[_index].completed = !todos[_index].completed;

        emit TodoCompleted(_index, todos[_index].text);
    }
}
