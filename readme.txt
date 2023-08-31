----------------------------
-- Hardware
----------------------------
To re-create a Vivado project:
0. Unzip the files of this archive to <your_directory>.
   Make sure the directory does not already contain a project with the same name. 
   You may run cleanup.cmd to delete everything except the utility files.
1. Open Vivado GUI 
2. Click Tools/Run Tcl Script
3. Browse for the <your_directory>\proj\create_project.tcl 
4. The project opens from <your_directory>\proj/proj_name\proj_name.xpr
5. The project is ready to compile for a Nexys4 DDR board. 
   If you want to compile it for a Nexys4 board: 
   - remove from the project constrains the file called Nexys4DDR_Master.xdc
   - add instead the file called Nexys4_Master.xdc. (<your_directory>\src\constraints)
