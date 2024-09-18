pragma solidity ^0.8.0;

interface IRule {
    function configure(bytes calldata data) external;
    function evaluate(bytes calldata data) external;
}

contract RuleCombinator is IRule {
    // Operator constants
    uint256 private constant OPERATOR_AND = 1;
    uint256 private constant OPERATOR_OR = 2;
    uint256 private constant OPERATOR_NOT = 3;

    // Expression stored as an array of bytes32 tokens
    bytes32[] private expression;

    /**
     * @notice Configures the RuleCombinator with a logical expression.
     * @param data ABI-encoded bytes32[] array representing the expression in RPN.
     */
    function configure(bytes calldata data) external override {
        // Decode the data into the expression array
        expression = abi.decode(data, (bytes32[]));
    }

    /**
     * @notice Evaluates the logical expression by combining inner rules.
     * @param data Additional data to pass to inner rule evaluations.
     */
    function evaluate(bytes calldata data) external override {
        // Initialize a stack for boolean values
        bool[] memory stack = new bool[](expression.length);
        uint256 stackPointer = 0;

        for (uint256 i = 0; i < expression.length; i++) {
            bytes32 token = expression[i];

            if (uint256(token) == OPERATOR_AND) {
                // Ensure there are at least two operands on the stack
                require(stackPointer >= 2, "Invalid expression: AND requires two operands");
                bool b = stack[--stackPointer];
                bool a = stack[--stackPointer];
                // Push the result of 'a AND b' onto the stack
                stack[stackPointer++] = a && b;
            } else if (uint256(token) == OPERATOR_OR) {
                // Ensure there are at least two operands on the stack
                require(stackPointer >= 2, "Invalid expression: OR requires two operands");
                bool b = stack[--stackPointer];
                bool a = stack[--stackPointer];
                // Push the result of 'a OR b' onto the stack
                stack[stackPointer++] = a || b;
            } else if (uint256(token) == OPERATOR_NOT) {
                // Ensure there is at least one operand on the stack
                require(stackPointer >= 1, "Invalid expression: NOT requires one operand");
                bool a = stack[--stackPointer];
                // Push the result of 'NOT a' onto the stack
                stack[stackPointer++] = !a;
            } else {
                // Assume the token is an address of an inner rule
                address ruleAddress = address(uint160(uint256(token)));
                IRule rule = IRule(ruleAddress);
                bool success;
                // Try to evaluate the inner rule
                try rule.evaluate(data) {
                    success = true;
                } catch {
                    success = false;
                }
                // Push the result onto the stack
                stack[stackPointer++] = success;
            }
        }

        // Ensure the final result is a single boolean value
        require(stackPointer == 1, "Invalid expression: incorrect final stack size");
        bool result = stack[0];

        // Revert if the overall evaluation fails
        if (!result) {
            revert("RuleCombinator: evaluation failed");
        }
    }
}
