unit testcases;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry, Forms, Unit1;

type

  TTestCase1= class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestReadUart;
    procedure TestReadWriteFile;
    procedure TestFeaturesTab;
    procedure TestBeeperTab;
    procedure TestSerialTab;
  end;

implementation

procedure TTestCase1.TestReadUart;
begin
  Form1.CurCfgList.Items.Clear();
  Form1.UartCombo.OnClick(nil);
  Form1.UartReadBtn.OnClick(nil);
  if Form1.CurCfgList.Items.Count > 0 then begin
   Form1.CurCfgList.ItemIndex := 0;
   Form1.CurCfgList.OnSelectionChange(nil, True);
  end
  //Form1.UartWriteBtn.OnClick(nil);
end;

procedure TTestCase1.TestReadWriteFile;
begin
  Form1.CurCfgList.Items.Clear();
  Form1.ActCfgList.Items.Clear();

  // Read test file
  Form1.OpenDialog.Filename := ExtractFilePath(Application.ExeName) + DirectorySeparator + 'test.cfg';
  Form1.FileReadBtn.OnClick(nil);
  Check(Form1.CurCfgList.Items.Count > 0, 'config lines not loaded');
  Form1.CurCfgList.ItemIndex := 0;
  Form1.CurCfgList.OnSelectionChange(nil, True);

  // Save test file
  Form1.FileNameEdit.Text := '';
  Form1.FileWriteBtn.OnClick(nil);
end;

procedure TTestCase1.TestFeaturesTab;
begin
  if Form1.CurCfgList.Items.Count = 0 then begin
   Form1.OpenDialog.Filename := ExtractFilePath(Application.ExeName) + DirectorySeparator + 'test.cfg';
   Form1.FileReadBtn.OnClick(nil);
   Check(Form1.CurCfgList.Items.Count > 0, 'config lines not loaded');
  end;

  Form1.DetailsTab.ActivePage := Form1.FeaturesTab;
  Form1.FeaturesTab.OnEnter(nil);
  Check(Form1.FeaturesList.Items.Count > 0, 'features not loaded');
  Form1.FeaturesList.ItemIndex := Form1.FeaturesList.Items.IndexOf('RX_SERIAL');
  Form1.FeaturesList.OnSelectionChange(nil, True);
  Form1.FeaturesList.OnClickCheck(nil);
  Check(Pos('feature', Form1.CurCfgList.Items[Form1.CurCfgList.ItemIndex]) > 0, 'feature line not selected');
  Form1.FeatureRcList.ItemIndex := 0;
  Form1.FeatureRcList.OnClick(Form1.FeatureRcList);
  Check(Pos('resource', Form1.CurCfgList.Items[Form1.CurCfgList.ItemIndex]) > 0, 'resource line not selected');
end;

procedure TTestCase1.TestBeeperTab;
begin
  if Form1.CurCfgList.Items.Count = 0 then begin
   Form1.OpenDialog.Filename := ExtractFilePath(Application.ExeName) + DirectorySeparator + 'test.cfg';
   Form1.FileReadBtn.OnClick(nil);
   Check(Form1.CurCfgList.Items.Count > 0, 'config lines not loaded');
  end;

  Form1.BeeperTab.OnEnter(nil);
  Check(Form1.BeeperList.Items.Count > 0, 'beeper alarms not loaded');
  Form1.BeeperList.ItemIndex := Form1.BeeperList.Items.IndexOf('RX_LOST');
  Form1.BeeperList.OnSelectionChange(nil, True);
  Form1.BeeperList.OnClickCheck(nil);
  Check(Pos('beeper', Form1.CurCfgList.Items[Form1.CurCfgList.ItemIndex]) > 0, 'beeper line not selected');
  Form1.BeeperRcList.ItemIndex := 0;
  Form1.BeeperRcList.OnClick(Form1.BeeperRcList);
  Check(Pos('resource', Form1.CurCfgList.Items[Form1.CurCfgList.ItemIndex]) > 0, 'resource line not selected');
end;

procedure TTestCase1.TestSerialTab;
begin
  if Form1.CurCfgList.Items.Count = 0 then begin
   Form1.OpenDialog.Filename := ExtractFilePath(Application.ExeName) + DirectorySeparator + 'test.cfg';
   Form1.FileReadBtn.OnClick(nil);
   Check(Form1.CurCfgList.Items.Count > 0, 'config lines not loaded');
  end;

  Form1.SerialTab.OnEnter(nil);
  Check(Form1.SerialList.Items.Count > 0, 'serial ports not loaded');
  Form1.SerialList.ItemIndex := Form1.SerialList.Items.IndexOf('1');
  Form1.SerialList.OnSelectionChange(nil, True);
  Check(Pos('serial', Form1.CurCfgList.Items[Form1.CurCfgList.ItemIndex]) > 0, 'serial line not selected');
  Form1.SerialRcList.ItemIndex := 0;
  Form1.SerialRcList.OnClick(Form1.SerialRcList);
  Check(Pos('resource', Form1.CurCfgList.Items[Form1.CurCfgList.ItemIndex]) > 0, 'resource line not selected');
  Form1.SerialFnBox.ItemIndex := Form1.SerialFnBox.Items.IndexOf('GPS');
  Form1.SerialFnBox.OnChange(nil);
  Form1.SerialBaudBox.ItemIndex := Form1.SerialBaudBox.Items.IndexOf('9600');
  Form1.SerialBaudBox.OnChange(nil);
end;

procedure TTestCase1.SetUp;
begin
  Form1.Show;
end;

procedure TTestCase1.TearDown;
begin
  Form1.Hide;
end;

initialization

  RegisterTest(TTestCase1);
end.

