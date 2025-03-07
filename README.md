# GridKid: A Terminal-Based Spreadsheet Application  

GridKid is a command-line spreadsheet application developed in Ruby as part of a semester-long project. The goal was to create a functional spreadsheet environment within the terminal, focusing on CLI-based interactions rather than traditional GUI elements. This project provided valuable experience in software architecture, interpreter development, and command-line application design.  

## Key Milestones  

### **Milestone 1: Core System Design**  
- Established the foundational structure of GridKid, including the grid interface and cell management system.  
- Designed and implemented primitive data structures to support spreadsheet operations.  

### **Milestone 2: Expression Parsing and Interpretation**  
- Developed a lexer and parser to handle user-entered expressions and formulas within cells.  
- Implemented support for variables, conditionals, loops, and function calls, allowing for dynamic spreadsheet logic.  

### **Milestone 3: Runtime Execution and Dependency Management**  
- Built a runtime environment to execute parsed expressions and update cell values dynamically.  
- Ensured dependency tracking between cells, allowing for automatic recalculations when referenced values changed.  

### **Milestone 4: Final Refinements and Enhancements**  
- Improved user interaction handling for a smoother command-line experience.  
- Strengthened error detection and handling to ensure stability and usability.  
- Conducted thorough testing to validate all defined features and requirements.  

## **Learning Outcomes**  
This project enhanced proficiency in Ruby programming while providing hands-on experience in:  
- **CLI-based application development**  
- **Interpreter and runtime system design**  
- **Software architecture and data management**  

Additionally, the focus on video documentation over automated grading encouraged a deeper understanding of project concepts and implementation details.  

## **How to Run GridKid**  
To run the GridKid application, open a command-line terminal, navigate to the project directory, and execute:  

```sh
ruby Interface.rb
