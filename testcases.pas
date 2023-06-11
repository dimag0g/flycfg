unit testcases;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry, Forms, Controls,
  IniFiles, LCLTranslator, LCLVersion, Unit1;

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
    procedure TestModesTab;
    procedure TestCtrlSizesRu;
    procedure TestCtrlSizesEn;
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
  end;
  Form1.UartCombo.Text := '';
  Form1.MenuWriteAll.OnClick(nil);
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

  Form1.FindBox.Text := 'resource';
  Form1.FindButton.OnClick(nil);
  Check(Pos('resource', Form1.CurCfgList.Items[Form1.CurCfgList.ItemIndex]) > 0, 'resource line not selected');

  // Save test file
  Form1.FileNameEdit.Text := '';
  Form1.FileWriteBtn.OnClick(nil);
end;

procedure TTestCase1.TestFeaturesTab;
begin
  if Form1.CurCfgList.Items.Count = 0 then begin
   Form1.OpenDialog.Filename := ExtractFilePath(Application.ExeName) + 'test.cfg';
   Form1.FileReadBtn.OnClick(nil);
   Check(Form1.CurCfgList.Items.Count > 0, 'config lines not loaded');
  end;

  Form1.DetailsTab.ActivePage := Form1.FeaturesTab;
  Form1.FeaturesTab.OnShow(nil);
  Check(Form1.FixFeaturesList.Items.IndexOf('ADC') >= 0, 'ADC feature not found');
  Form1.FixFeaturesList.ItemIndex := Form1.FixFeaturesList.Items.IndexOf('ADC');
  Form1.FixFeaturesList.OnSelectionChange(nil, True);
  Check(Form1.FeaturesList.Items.IndexOf('RX_SERIAL') >= 0, 'RX_SERIAL feature not found');
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

  Form1.BeeperTab.OnShow(nil);
  Check(Form1.BeeperList.Items.Count > 0, 'beeper alarms not loaded');
  Check(Form1.BeeperList.Items.IndexOf('RX_LOST') >= 0, 'RX_LOST alarm not found');
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

  Form1.SerialTab.OnShow(nil);
  Check(Form1.SerialList.Items.Count > 0, 'serial ports not loaded');
  Form1.SerialList.ItemIndex := Form1.SerialList.Items.IndexOf('1');
  Form1.SerialList.OnSelectionChange(nil, True);
  Check(Pos('serial', Form1.CurCfgList.Items[Form1.CurCfgList.ItemIndex]) > 0, 'serial line not selected');
  Form1.SerialRcList.ItemIndex := 0;
  Form1.SerialRcList.OnClick(Form1.SerialRcList);
  Check(Pos('resource', Form1.CurCfgList.Items[Form1.CurCfgList.ItemIndex]) > 0, 'resource line not selected');
  Check(Form1.SerialFnBox.Items.IndexOf('GPS') >= 0, 'GPS function not found');
  Form1.SerialFnBox.ItemIndex := Form1.SerialFnBox.Items.IndexOf('GPS');
  Form1.SerialFnBox.OnChange(nil);
  Check(Form1.SerialBaudBox.Items.IndexOf('9600') >= 0, 'baudrate 9600 not found');
  Form1.SerialBaudBox.ItemIndex := Form1.SerialBaudBox.Items.IndexOf('9600');
  Form1.SerialBaudBox.OnChange(nil);
end;

procedure TTestCase1.TestModesTab;
begin
  if Form1.CurCfgList.Items.Count = 0 then begin
   Form1.OpenDialog.Filename := ExtractFilePath(Application.ExeName) + DirectorySeparator + 'test.cfg';
   Form1.FileReadBtn.OnClick(nil);
   Check(Form1.CurCfgList.Items.Count > 0, 'config lines not loaded');
  end;

  Form1.ModesTab.OnShow(nil);
  Check(Form1.ModesList.Items.Count > 0, 'modes not loaded');
  Form1.ModesList.ItemIndex := 0;
  Form1.ModesList.OnSelectionChange(nil, True);
  Check(Pos('aux', Form1.CurCfgList.Items[Form1.CurCfgList.ItemIndex]) > 0, 'serial line not selected');
  Check(Form1.ModeNameCombo.Items.IndexOf('ARM') >= 0, 'ARM mode not found');
  Form1.ModeNameCombo.ItemIndex := Form1.ModeNameCombo.Items.IndexOf('ARM');
  Form1.ModeNameCombo.OnChange(nil);
end;

function TestCtrlSizes: String;
var
  i: Integer;
  w, h: Integer;
begin
  w := 0;
  h := 0;
  Result := '';
  for i:=0 to Form1.ComponentCount-1 do begin
    if (Form1.Components[i] is TControl) then
      with Form1.Components[i] as TControl do begin
        GetPreferredSize(w, h);
        if not (Width >= w) then begin
          Result := Result + 'Width too small, caption: "' + Caption +
                             '", width: ' + IntToStr(Width) +
                             ', pref: ' + IntToStr(w) + LineEnding;
        end;
        if not (Height >= h) then begin
          Result := Result + 'Height too small, caption: "' + Caption +
                             '", height: ' + IntToStr(Height) +
                             ', pref: ' + IntToStr(h) + LineEnding;
        end;
      end;
  end;
end;

procedure TTestCase1.TestCtrlSizesRu;
var
  s: String;
begin
  {$IF LCL_FullVersion >= 2001000}
  SetDefaultLang('ru', '', 'flycfg');
  s := TestCtrlSizes;
  Check(s = '', s);
  {$ELSE}
  {$WARNING Translations cannot be unit-tested with this version of Lazarus}
  {$ENDIF}
end;

procedure TTestCase1.TestCtrlSizesEn;
var
  s: String;
begin
  {$IF LCL_FullVersion >= 2001000}
  SetDefaultLang('en', '', 'flycfg');
  {$ENDIF}
  s := TestCtrlSizes;
  Check(s = '', s);
end;

procedure TTestCase1.SetUp;
begin
  {$IFDEF UNIX}
  Form1.Config.Destroy;
  Form1.Config := TMemIniFile.Create(ExtractFilePath(Application.ExeName) + 'flycfg.ini');
  {$ENDIF}
  Form1.Show;
end;

procedure TTestCase1.TearDown;
begin
  Form1.Hide;
end;

initialization

  RegisterTest(TTestCase1);
end.

