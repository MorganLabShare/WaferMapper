%%Create Excel system logbook for each Wafer


bookName = [GuiGlobalsStruct.WaferDirectory '\systemLogBook.xlsx'];
A = {'test1'},
sheet = 'testSheet'

xlswrite(bookName,A,sheet)