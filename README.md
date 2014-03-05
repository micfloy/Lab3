Lab3
====

Font Controller Lab

#Introduction

Problem:
The problem in this lab was to create a font controller that would display a screen of ASCII characters and allow the user to change each character on the screen using an array of switches and a button on the Atlys boards we are using.  

Solution:
In order to solve this, I was provided several components to interface with the ASCII ROM, but had to connect them inside of a `char_gen` module.  I began with the diagram provided on the course website for `char_gen` and instantiated each of the components given to me.  I then created the remaining components and necessary delay registers and connected all of the inputs and outputs as described in the lab.  Once `char_gen` was complete, there were only minor changes and additions that had to be made to the user constraints file and the top level controller in order to interface with the switches and buttons on the board.  Overall, the design process was very straightforward.

Currently, the design allows the user to select an ASCII character from a small library using the positions of 8 switches and the 'up' button on the Atlys board, oriented with the switches towards the user.



#Modules

This is a brief overview of the components I created for this lab.

##`atlys_lab_font_controller`

###Block Diagram

![Very blocked, such diagram](https://raw.github.com/micfloy/Lab3/master/schematic.PNG)

As can easily be seen, the majority of the components were connected within `char_gen` and components from the previous labs were connected in the top level design.

```VHD
entity atlys_lab_font_controller is
    port ( 
             clk    : in  std_logic; -- 100 MHz
             reset  : in  std_logic;
             start  : in  std_logic;
				     button_input : std_logic;
             switch : in  std_logic_vector(7 downto 0);
             led    : out std_logic_vector(7 downto 0);
             tmds   : out std_logic_vector(3 downto 0);
             tmdsb  : out std_logic_vector(3 downto 0)
         );
end atlys_lab_font_controller;
```

The largest additions to this module from Lab2 were the 8 switch inputs instead of 1 as well as several delay registers.  These were necessary to account for the piping delays in the `char_gen` module.  Also, the updated `input_to_pulse` component was used in this design.


##`char_gen`

```VHD
entity char_gen is
    port ( clk            : in std_logic;
           blank          : in std_logic;
			     reset			    : in std_logic;
           row            : in std_logic_vector(10 downto 0);
           column         : in std_logic_vector(10 downto 0);
           ascii_to_write : in std_logic_vector(7 downto 0);
           write_en       : in std_logic;
           r,g,b          : out std_logic_vector(7 downto 0)
         );
end char_gen;
```

The largest problem to solve in this module was to properly set up the outputs `r,g,b` and getting all of the signal connections to be the correct sizes and types.  There was also some confusing array math that had to be done in order to increment by the size of each character when traversing the screen.
For example:
```VHD
row_col_sig <= std_logic_vector(unsigned(row(10 downto 4))* 80 + unsigned(column(10 downto 3)));
```

In order to properly assign the output values for `r,g,b`, an 8-1 MUX had to be created.  For modularity I chose to create a separate component for this and instantiate it within `char_gen`.

###`MUX81`

```VHD
entity MUX81 is
    Port ( sel : in  STD_LOGIC_VECTOR (2 downto 0);
           data : in  STD_LOGIC_VECTOR (7 downto 0);
           output : out  STD_LOGIC);
end MUX81;
```
This was a very simple module once I understood its purpose fully.  It simply had to select a bit of a data signal for a given row in the character.  This bit was then set to the value or a color.  For my design, when a bit was high, I set `g` to binary 255 so that all of my characters would appear in green.

##`input_to_pulse`

This module was based on my button module for Lab2, but made more generic to apply to more possible situations in the future.

###State Diagram

![Triangle of Death](https://raw.github.com/micfloy/Lab3/master/button_state_diagram.PNG)

This diagram shows the outline of how the machine behaves.  The essential element is the debouncing that occurs inside of `button_held` state.  This prevents the button from pulsing multiple times with each press.

```VHD
entity input_to_pulse is
    port ( clk          : in std_logic;
           reset        : in std_logic;
           input        : in std_logic;
           pulse        : out std_logic
         );
end input_to_pulse;
```
The inputs and outputs are very straightforward.  It is essentially just a combination of counting registers with a state machine.

##`vga_sync`

`vga_sync` was also included in this repo for completeness, however, this code is essentially unchanged from Lab2.

#Testing

The testing for this lab, like Lab2, was mostly visual.  I began with a systematic approach to creat the smallest component needed, the MUX, and then build all of the connections inside of `char_gen`.  Overall, I would say that once I understood the problem, testing and debuggin was much smoother for this lab than Lab2.  I had very few errors that I spent more than 20 minutes fixing.  My biggest problem was getting my signal sizes correct, especially when performing mathematical operations on multiple signals.  usually I was able to see right away that this was the problem from the error reports.  Unlike some VHDL errors, incorrect signal sizes are very clearly described.

I also had a lot of issues with name confusion for my signals due to the large number of similar signals and especially all of the intermediate delay register signals.  eventually I was able to track down all of these and fix them, but this was probably my biggest delay in coding.

#Conclusion

I thought that this lab was far more acheivable for me than the previous labs, at least for Required and B functionality.  I admit that I gave up without completing A functionality due to my workload in other courses.  I regret this primarily because I think that interfacing with something like an NES controller could very well be part of my final project and I would have liked to get a head start on how to do that.  This is something I am hoping to work out in the future either way.

I found this lab to be the least frustrating so far and definitely within my abilities.  It was also nice to see that I could apply all of the lessons I had learned from lab 1 and 2.
