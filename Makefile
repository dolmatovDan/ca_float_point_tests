# Test Makefile - Shared testing system
# Usage: EXECUTABLE=./your_program make test

# Test executable (can be overridden with EXECUTABLE env var)
EXECUTABLE ?= ./main

# Comparator script
COMPARATOR ?= python3 compare.py

# Test filter regex (optional - filters test names)
FILTER ?= .*

# Temporary directory for cross-platform compatibility
TEMP_DIR = ./.temp

# Run all tests (only shows failed tests)
test:
	@echo "Running tests with filter: $(FILTER)"
	@mkdir -p $(TEMP_DIR); \
	test_count=0; \
	passed_count=0; \
	failed_count=0; \
	for user_dir in tests/*/; do \
		if [ -d "$$user_dir" ]; then \
			user_name=$$(basename "$$user_dir"); \
			user_has_matching_tests=false; \
			for test_dir in "$$user_dir"*/; do \
				if [ -d "$$test_dir" ]; then \
					test_name=$$(basename "$$test_dir"); \
					full_test_name="$$user_name/$$test_name"; \
					if echo "$$full_test_name" | grep -E "$(FILTER)" >$(TEMP_DIR)/grep_out 2>$(TEMP_DIR)/grep_err; then \
						if [ "$$user_has_matching_tests" = "false" ]; then \
							echo "Running tests for user: $$user_name"; \
							user_has_matching_tests=true; \
						fi; \
						test_count=$$((test_count + 1)); \
						actual_output=$$(cat "$$test_dir"in.txt | xargs $(EXECUTABLE)); \
						if $(COMPARATOR) "$$test_dir/out.txt" "$$actual_output"; then \
							passed_count=$$((passed_count + 1)); \
						else \
							echo "Running test: $$user_name/$$test_name"; \
							echo "Input: $$(cat "$$test_dir/in.txt")"; \
							echo "Expected output: $$(cat "$$test_dir/out.txt")"; \
							echo "Actual output:"; \
							echo "$$actual_output"; \
							echo "✗ FAILED"; \
							failed_count=$$((failed_count + 1)); \
							echo ""; \
						fi; \
					fi; \
				fi; \
			done; \
		fi; \
	done; \
	echo "Test Summary: $$passed_count/$$test_count passed, $$failed_count failed"; \
	rm -rf $(TEMP_DIR)

# Run all tests (verbose version - shows all tests)
test-verbose:
	@echo "Running tests with verbose output and filter: $(FILTER)"
	@mkdir -p $(TEMP_DIR); \
	test_count=0; \
	passed_count=0; \
	failed_count=0; \
	for user_dir in tests/*/; do \
		if [ -d "$$user_dir" ]; then \
			user_name=$$(basename "$$user_dir"); \
			user_has_matching_tests=false; \
			for test_dir in "$$user_dir"*/; do \
				if [ -d "$$test_dir" ]; then \
					test_name=$$(basename "$$test_dir"); \
					full_test_name="$$user_name/$$test_name"; \
					if echo "$$full_test_name" | grep -E "$(FILTER)" >$(TEMP_DIR)/grep_out 2>$(TEMP_DIR)/grep_err; then \
						if [ "$$user_has_matching_tests" = "false" ]; then \
							echo "=========================================="; \
							echo "Running tests for user: $$user_name"; \
							echo "=========================================="; \
							user_has_matching_tests=true; \
						fi; \
						test_count=$$((test_count + 1)); \
						echo "------------------------------------------"; \
						echo "Test directory: $$test_dir"; \
						echo "Test name: $$user_name/$$test_name"; \
						echo "Input: $$(cat "$$test_dir/in.txt")"; \
						echo "Expected output: $$(cat "$$test_dir/out.txt")"; \
						echo "Actual output:"; \
						actual_output=$$(cat "$$test_dir"in.txt | xargs $(EXECUTABLE)); \
						echo "$$actual_output"; \
						if $(COMPARATOR) "$$test_dir/out.txt" "$$actual_output"; then \
							echo "✓ PASSED"; \
							passed_count=$$((passed_count + 1)); \
						else \
							echo "✗ FAILED"; \
							echo "Expected: '$$(cat "$$test_dir/out.txt")'"; \
							echo "Got: '$$actual_output'"; \
							failed_count=$$((failed_count + 1)); \
						fi; \
						echo "------------------------------------------"; \
						echo ""; \
					fi; \
				fi; \
			done; \
		fi; \
	done; \
	echo "Test Summary: $$passed_count/$$test_count passed, $$failed_count failed"; \
	rm -rf $(TEMP_DIR)

# Run specific test (usage: make test-single TEST=tests/dandolmatov/mult_0_1)
test-single:
	@if [ -z "$(TEST)" ]; then \
		mkdir -p $(TEMP_DIR); \
		echo "Usage: make test-single TEST=tests/<user>/<test_name>"; \
		echo "Example: make test-single TEST=tests/dandolmatov/mult_0_1"; \
		echo "Available tests matching filter '$(FILTER)':"; \
		for user_dir in tests/*/; do \
			if [ -d "$$user_dir" ]; then \
				user_name=$$(basename "$$user_dir"); \
				user_has_matching_tests=false; \
				for test_dir in "$$user_dir"*/; do \
					if [ -d "$$test_dir" ]; then \
						test_name=$$(basename "$$test_dir"); \
						full_test_name="$$user_name/$$test_name"; \
						if echo "$$full_test_name" | grep -E "$(FILTER)" >$(TEMP_DIR)/grep_out 2>$(TEMP_DIR)/grep_err; then \
							if [ "$$user_has_matching_tests" = "false" ]; then \
								echo "  User: $$user_name"; \
								user_has_matching_tests=true; \
							fi; \
							echo "    $$user_name/$$test_name"; \
						fi; \
					fi; \
				done; \
			fi; \
		done; \
		rm -rf $(TEMP_DIR); \
		exit 1; \
	fi
	@if [ ! -d "$(TEST)" ]; then \
		mkdir -p $(TEMP_DIR); \
		echo "Test directory $(TEST) not found!"; \
		echo "Available tests matching filter '$(FILTER)':"; \
		for user_dir in tests/*/; do \
			if [ -d "$$user_dir" ]; then \
				user_name=$$(basename "$$user_dir"); \
				user_has_matching_tests=false; \
				for test_dir in "$$user_dir"*/; do \
					if [ -d "$$test_dir" ]; then \
						test_name=$$(basename "$$test_dir"); \
						full_test_name="$$user_name/$$test_name"; \
						if echo "$$full_test_name" | grep -E "$(FILTER)" >$(TEMP_DIR)/grep_out 2>$(TEMP_DIR)/grep_err; then \
							if [ "$$user_has_matching_tests" = "false" ]; then \
								echo "  User: $$user_name"; \
								user_has_matching_tests=true; \
							fi; \
							echo "    $$user_name/$$test_name"; \
						fi; \
					fi; \
				done; \
			fi; \
		done; \
		rm -rf $(TEMP_DIR); \
		exit 1; \
	fi
	@if [ ! -f "$(TEST)/in.txt" ]; then \
		echo "Input file $(TEST)/in.txt not found!"; \
		exit 1; \
	fi
	@if [ ! -f "$(TEST)/out.txt" ]; then \
		echo "Expected output file $(TEST)/out.txt not found!"; \
		exit 1; \
	fi
	@echo "=========================================="; \
	echo "Test directory: $(TEST)"; \
	echo "Input: $$(cat "$(TEST)/in.txt")"; \
	echo "Expected output: $$(cat "$(TEST)/out.txt")"; \
	echo "Actual output:"; \
	actual_output=$$(cat "$(TEST)/in.txt" | xargs $(EXECUTABLE)); \
	echo "$$actual_output"; \
	if $(COMPARATOR) "$(TEST)/out.txt" "$$actual_output"; then \
		echo "✓ PASSED"; \
	else \
		echo "✗ FAILED"; \
		echo "Expected: '$$(cat "$(TEST)/out.txt")'"; \
		echo "Got: '$$actual_output'"; \
	fi; \
	echo "=========================================="

# Show help
help:
	@echo "Test Makefile - Shared testing system"
	@echo ""
	@echo "Usage:"
	@echo "  EXECUTABLE=./your_program make test                                   # Run all tests (show only failures)"
	@echo "  EXECUTABLE=./your_program make test-verbose                           # Run all tests (show all)"
	@echo "  EXECUTABLE=./your_program make test-single TEST=tests/user/test_name  # Run single test"
	@echo "  make clean                                                             # Clean temporary files"
	@echo ""
	@echo "Environment Variables:"
	@echo "  EXECUTABLE - Path to the executable to test (default: ./main)"
	@echo "  COMPARATOR - Path to the comparator script (default: python3 compare.py)"
	@echo "  FILTER     - Regex to filter test names (default: .* - matches all)"
	@echo ""
	@echo "Files Required:"
	@echo "  compare.py - Output comparison script (must be in current directory)"
	@echo ""
	@echo "Note:"
	@echo "  A temporary directory (./.temp) is created during test execution for cross-platform compatibility"
	@echo ""
	@echo "Test Structure:"
	@echo "  Each test should be in tests/<user>/<test_name>/ with:"
	@echo "    - in.txt  (input)"
	@echo "    - out.txt (expected output)"
	@echo ""
	@echo "Examples:"
	@echo "  EXECUTABLE=./my_program make test"
	@echo "  EXECUTABLE=python3 my_script.py make test"
	@echo "  EXECUTABLE=./my_program make test-single TEST=dandolmatov/mult_0_1"
	@echo ""
	@echo "Filter Examples:"
	@echo "  FILTER='plus_' make test                      # Run only plus operation tests"
	@echo "  FILTER='itmo/mult_.*_1' make test             # Run itmo mult tests ending in _1"
	@echo "  FILTER='dandolmatov' make test-verbose        # Run only dandolmatov's tests"
	@echo "  FILTER='_(0|1)_' make test                    # Run tests with type 0 or 1"

# Clean temporary files
clean:
	@rm -rf $(TEMP_DIR)
	@echo "Temporary files cleaned"

# Phony targets
.PHONY: test test-verbose test-single check-executable check-comparator help clean
