unit TestCasesGui;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry, Forms, Controls,
  IniFiles, LCLTranslator, LCLVersion, FlyCfgGui;

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
  MainForm.CurCfgList.Items.Clear();
  MainForm.UartCombo.OnClick(nil);
  MainForm.UartReadBtn.OnClick(nil);
  if MainForm.CurCfgList.Items.Count > 0 then begin
   MainForm.CurCfgList.ItemIndex := 0;
   MainForm.CurCfgList.OnSelectionChange(nil, True);
  end;
  MainForm.UartCombo.Text := '';
  MainForm.MenuWriteAll.OnClick(nil);
end;

procedure TTestCase1.TestReadWriteFile;
begin
  MainForm.CurCfgList.Items.Clear();
  MainForm.ActCfgList.Items.Clear();

  // Read test file
  MainForm.OpenDialog.Filename := ExtractFilePath(Application.ExeName) + DirectorySeparator + 'test.cfg';
  MainForm.FileReadBtn.OnClick(nil);
  Check(MainForm.CurCfgList.Items.Count > 0, 'config lines not loaded');
  MainForm.CurCfgList.ItemIndex := 0;
  MainForm.CurCfgList.OnSelectionChange(nil, True);

  MainForm.FindBox.Text := 'resource';
  MainForm.FindButton.OnClick(nil);
  Check(Pos('resource', MainForm.CurCfgList.Items[MainForm.CurCfgList.ItemIndex]) > 0, 'resource line not selected');

  // Save test file
  MainForm.FileNameEdit.Text := '';
  MainForm.FileWriteBtn.OnClick(nil);
end;

procedure TTestCase1.TestFeaturesTab;
begin
  if MainForm.CurCfgList.Items.Count = 0 then begin
   MainForm.OpenDialog.Filename := ExtractFilePath(Application.ExeName) + 'test.cfg';
   MainForm.FileReadBtn.OnClick(nil);
   Check(MainForm.CurCfgList.Items.Count > 0, 'config lines not loaded');
  end;

  MainForm.DetailsTab.ActivePage := MainForm.FeaturesTab;
  MainForm.FeaturesTab.OnShow(nil);
  Check(MainForm.FixFeaturesList.Items.IndexOf('ADC') >= 0, 'ADC feature not found');
  MainForm.FixFeaturesList.ItemIndex := MainForm.FixFeaturesList.Items.IndexOf('ADC');
  MainForm.FixFeaturesList.OnSelectionChange(nil, True);
  Check(MainForm.FeaturesList.Items.IndexOf('RX_SERIAL') >= 0, 'RX_SERIAL feature not found');
  MainForm.FeaturesList.ItemIndex := MainForm.FeaturesList.Items.IndexOf('RX_SERIAL');
  MainForm.FeaturesList.OnSelectionChange(nil, True);
  MainForm.FeaturesList.OnClickCheck(nil);
  Check(Pos('feature', MainForm.CurCfgList.Items[MainForm.CurCfgList.ItemIndex]) > 0, 'feature line not selected');
  MainForm.FeatureRcList.ItemIndex := 0;
  MainForm.FeatureRcList.OnClick(MainForm.FeatureRcList);
  Check(Pos('resource', MainForm.CurCfgList.Items[MainForm.CurCfgList.ItemIndex]) > 0, 'resource line not selected');
end;

procedure TTestCase1.TestBeeperTab;
begin
  if MainForm.CurCfgList.Items.Count = 0 then begin
   MainForm.OpenDialog.Filename := ExtractFilePath(Application.ExeName) + DirectorySeparator + 'test.cfg';
   MainForm.FileReadBtn.OnClick(nil);
   Check(MainForm.CurCfgList.Items.Count > 0, 'config lines not loaded');
  end;

  MainForm.DetailsTab.ActivePage := MainForm.BeeperTab;
  MainForm.BeeperTab.OnShow(nil);
  Check(MainForm.BeeperList.Items.Count > 0, 'beeper alarms not loaded');
  Check(MainForm.BeeperList.Items.IndexOf('RX_LOST') >= 0, 'RX_LOST alarm not found');
  MainForm.BeeperList.ItemIndex := MainForm.BeeperList.Items.IndexOf('RX_LOST');
  MainForm.BeeperList.OnSelectionChange(nil, True);
  MainForm.BeeperList.OnClickCheck(nil);
  Check(Pos('beeper', MainForm.CurCfgList.Items[MainForm.CurCfgList.ItemIndex]) > 0, 'beeper line not selected');
  MainForm.BeeperRcList.ItemIndex := 0;
  MainForm.BeeperRcList.OnClick(MainForm.BeeperRcList);
  Check(Pos('resource', MainForm.CurCfgList.Items[MainForm.CurCfgList.ItemIndex]) > 0, 'resource line not selected');
end;

procedure TTestCase1.TestSerialTab;
begin
  if MainForm.CurCfgList.Items.Count = 0 then begin
   MainForm.OpenDialog.Filename := ExtractFilePath(Application.ExeName) + DirectorySeparator + 'test.cfg';
   MainForm.FileReadBtn.OnClick(nil);
   Check(MainForm.CurCfgList.Items.Count > 0, 'config lines not loaded');
  end;

  MainForm.DetailsTab.ActivePage := MainForm.SerialTab;
  MainForm.SerialTab.OnShow(nil);
  Check(MainForm.SerialList.Items.Count > 0, 'serial ports not loaded');
  MainForm.SerialList.ItemIndex := MainForm.SerialList.Items.IndexOf('1');
  MainForm.SerialList.OnSelectionChange(nil, True);
  Check(Pos('serial', MainForm.CurCfgList.Items[MainForm.CurCfgList.ItemIndex]) > 0, 'serial line not selected');
  MainForm.SerialRcList.ItemIndex := 0;
  MainForm.SerialRcList.OnClick(MainForm.SerialRcList);
  Check(Pos('resource', MainForm.CurCfgList.Items[MainForm.CurCfgList.ItemIndex]) > 0, 'resource line not selected');
  Check(MainForm.SerialFnBox.Items.IndexOf('GPS') >= 0, 'GPS function not found');
  MainForm.SerialFnBox.ItemIndex := MainForm.SerialFnBox.Items.IndexOf('GPS');
  MainForm.SerialFnBox.OnChange(nil);
  Check(MainForm.SerialBaudBox.Items.IndexOf('9600') >= 0, 'baudrate 9600 not found');
  MainForm.SerialBaudBox.ItemIndex := MainForm.SerialBaudBox.Items.IndexOf('9600');
  MainForm.SerialBaudBox.OnChange(nil);
end;

procedure TTestCase1.TestModesTab;
begin
  if MainForm.CurCfgList.Items.Count = 0 then begin
   MainForm.OpenDialog.Filename := ExtractFilePath(Application.ExeName) + DirectorySeparator + 'test.cfg';
   MainForm.FileReadBtn.OnClick(nil);
   Check(MainForm.CurCfgList.Items.Count > 0, 'config lines not loaded');
  end;

  MainForm.DetailsTab.ActivePage := MainForm.ModesTab;
  MainForm.ModesTab.OnShow(nil);
  Check(MainForm.ModesList.Items.Count > 0, 'modes not loaded');
  MainForm.ModesList.ItemIndex := 0;
  MainForm.ModesList.OnSelectionChange(nil, True);
  Check(Pos('aux', MainForm.CurCfgList.Items[MainForm.CurCfgList.ItemIndex]) > 0, 'serial line not selected');
  Check(MainForm.ModeNameCombo.Items.IndexOf('ARM') >= 0, 'ARM mode not found');
  MainForm.ModeNameCombo.ItemIndex := MainForm.ModeNameCombo.Items.IndexOf('ARM');
  MainForm.ModeNameCombo.OnChange(nil);
end;

function TestCtrlSizes: String;
var
  i: Integer;
  w, h: Integer;
begin
  w := 0;
  h := 0;
  Result := '';
  for i:=0 to MainForm.ComponentCount-1 do begin
    if (MainForm.Components[i] is TControl) then
      with MainForm.Components[i] as TControl do begin
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
  {$IF LCL_FullVersion > 2001000}
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
  {$IF LCL_FullVersion > 2001000}
  SetDefaultLang('en', '', 'flycfg');
  {$ENDIF}
  s := TestCtrlSizes;
  Check(s = '', s);
end;

procedure TTestCase1.SetUp;
begin
  {$IFDEF UNIX}
  MainForm.Config.Destroy;
  MainForm.Config := TMemIniFile.Create(ExtractFilePath(Application.ExeName) + 'flycfg.ini');
  {$ENDIF}
  MainForm.Show;
end;

procedure TTestCase1.TearDown;
begin
  MainForm.Hide;
end;

initialization

  RegisterTest(TTestCase1);
end.

