program fpcunittest;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, testcases, Unit1, LazSerialPort;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

