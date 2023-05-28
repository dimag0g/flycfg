unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, CheckLst, Menus, EditBtn, IniFiles, lazsynaser, LazSerial, Types,
  Math, LCLType; // Grids

type

  { TForm1 }

  TForm1 = class(TForm)
    AutoComleteList: TListBox;
    BeeperList: TCheckListBox;
    ActCfgList: TListBox;
    CurCfgGroup: TGroupBox;
    FileNameEdit: TEdit;
    Label3: TLabel;
    LazSerial1: TLazSerial;
    LogClearButton: TButton;
    FixFeaturesList: TListBox;
    Label21: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label8: TLabel;
    LogList: TListBox;
    StatusLabel: TLabel;
    ProgressBar: TProgressBar;
    SerialRcList: TListBox;
    SerialBaudBox: TComboBox;
    SerialFnBox: TComboBox;
    FindButton: TButton;
    FindBox: TComboBox;
    CurCfgList: TListBox;
    FileReadBtn: TButton;
    FileWriteBtn: TButton;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    BeeperRcList: TListBox;
    SerialList: TListBox;
    Label4: TLabel;
    FeatureRcList: TListBox;
    FeaturesList: TCheckListBox;
    Label1: TLabel;
    ActiveRcList: TListBox;
    Label2: TLabel;
    Label5: TLabel;
    DiffCfgList: TListBox;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    BeeperTab: TTabSheet;
    SerialTab: TTabSheet;
    DebugTab: TTabSheet;
    LogTab: TTabSheet;
    UartWriteBtn: TButton;
    UartReadBtn: TButton;
    LoadDefaultBtn: TButton;
    UartCombo: TComboBox;
    DetailsTab: TPageControl;
    FeaturesTab: TTabSheet;
    procedure BeeperListClickCheck(Sender: TObject);
    procedure BeeperListSelectionChange(Sender: TObject; User: boolean);
    procedure CfgListClick(Sender: TObject);
    procedure BeeperTabEnter(Sender: TObject);
    procedure CurCfgListClick(Sender: TObject);
    procedure CurCfgListDblClick(Sender: TObject);
    procedure CurCfgListSelectionChange(Sender: TObject; User: boolean);
    procedure CurToDiffBtnClick(Sender: TObject);
    procedure DiffToCurBtnClick(Sender: TObject);
    procedure FeaturesListClickCheck(Sender: TObject);
    procedure FeaturesListSelectionChange(Sender: TObject; User: boolean);
    procedure CfgListDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FeaturesTabEnter(Sender: TObject);
    procedure FileReadBtnClick(Sender: TObject);
    procedure FileWriteBtnClick(Sender: TObject);
    procedure FindButtonClick(Sender: TObject);
    procedure FixFeaturesListSelectionChange(Sender: TObject; User: boolean);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure LoadDefaultBtnClick(Sender: TObject);
    procedure LogClearButtonClick(Sender: TObject);
    procedure SerialListSelectionChange(Sender: TObject; User: boolean);
    procedure SerialTabEnter(Sender: TObject);
    procedure UartComboClick(Sender: TObject);
    procedure UartReadBtnClick(Sender: TObject);
    procedure CfgListDblClick(Sender: TObject);
    procedure UartWriteBtnClick(Sender: TObject);
  private
    Serial: TBlockSerial;
    Config: TIniFile;

    // Proportional resize variables
    FormWidth: Integer;
    GroupWidth: Integer;
    TabWidth: Integer;
    TabLeft: Integer;

    // Config line statuses
    CfgLineSts: array of Integer;

    procedure CurCfgShowLine(s: String);
    function CfgCalcSts(index: Integer): Integer;
    function UartConnect(): Boolean;
    procedure GetRcByFeature(feature: String; RcList: TStrings);
  public

  end;

const
  CFG_LINE_INACTIVE = $0001; // OFF, NONE, etc.
  CFG_LINE_COMMENT  = $0002; // Comments and info lines
  CFG_MASK_GRAY     = $000F;
  CFG_LINE_IN_DIFF  = $0010;
  CFG_MASK_GREEN    = $00F0;
  CFG_LINE_UNSAVED  = $0100;
  CFG_MASK_BLUE     = $0F00;
  CFG_LINE_NO_ALLOC = $1000; // Resource not allocated
  CFG_LINE_NO_NAME  = $2000; // Invalid setting name
  CFG_LINE_INVALID  = $2000; // Invalid value
  CFG_MASK_RED      = $F000;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
{$PUSH}{$WARN 5024 OFF}
begin
  Config.Destroy;
  Serial.Destroy;
end;
{$POP}

procedure TForm1.FormCreate(Sender: TObject);
begin
  FormWidth := Width;
  TabWidth := DetailsTab.Width;
  TabLeft := DetailsTab.Left;
  GroupWidth := CurCfgGroup.Width;

  setLength(CfgLineSts, 10000);

  UartCombo.OnClick(Sender);
  Serial := TBlockSerial.Create;
  Config := TIniFile.Create(ExtractFilePath(Application.ExeName) + DirectorySeparator + 'flycfg.ini');
  DetailsTab.ActivePage := FeaturesTab;
  {$IFOPT D+}
  DebugTab.TabVisible := True;
  LogTab.TabVisible := True;
  {$ENDIF}
end;

procedure TForm1.FormResize(Sender: TObject);
var
  ExtraWidth: Integer;
begin
  ExtraWidth := (Width - FormWidth) Div 2;

  DetailsTab.Width := TabWidth + ExtraWidth;
  DetailsTab.Left := TabLeft + ExtraWidth;
  CurCfgGroup.Width := GroupWidth + ExtraWidth;
end;

procedure TForm1.CurCfgShowLine(s: String);
var
  i: Integer;
begin
  for i := CurCfgList.Items.Count-1 downto 0 do begin
    if CurCfgList.Items[i] = s then begin
       CurCfgList.ItemIndex := i;
       break;
    end;
  end;
end;

function TForm1.CfgCalcSts(index: Integer): Integer;
var
  s: String;
  fields: TStringArray;
  autoFields: TStringArray;
  ignores: TStringArray;
  i: Integer;
begin
  Result := 0;
  s := CurCfgList.Items[index];
  if s = '' then begin
    Result := CFG_LINE_COMMENT;
  end else begin
    if DiffCfgList.Items.IndexOf(s) >= 0 then Result := Result or CFG_LINE_IN_DIFF;
    if (ActCfgList.Items.Count <= index) or (ActCfgList.Items[index] <> s) then begin
      if ActCfgList.Items.IndexOf(s) < 0 then Result := Result or CFG_LINE_UNSAVED;
    end;

    fields := s.Split(' ', TStringSplitOptions.ExcludeEmpty); // s is recycled at this point
    ignores := Config.ReadString('general', 'CFG_IGNORE_LINES', '#').Split(',');
    for s in ignores do begin
      if fields[0] = s then Result := CFG_LINE_COMMENT;
    end;

    if fields[0] = 'feature' then begin
      if fields[1][1] = '-' then Result := Result or CFG_LINE_INACTIVE;
    end else if fields[0] = 'set' then begin
      if fields[3] = 'OFF' then Result := Result or CFG_LINE_INACTIVE;
      if fields[3] = 'NONE' then Result := Result or CFG_LINE_INACTIVE;

      i := 0;
      for i := 0 to AutoComleteList.Items.Count-2 do begin
        if Pos(fields[1] + ' = ', AutoComleteList.Items[i]) = 1 then begin
           s := AutoComleteList.Items[i+1];
           autoFields := s.Split(' ', TStringSplitOptions.ExcludeEmpty);
           if autoFields[0] <> 'Allowed' then begin
             s := AutoComleteList.Items[i+2];
             autoFields := s.Split(' ', TStringSplitOptions.ExcludeEmpty);
             if autoFields[0] <> 'Allowed' then break;
           end;
           if autoFields[1] = 'range:' then begin
             if StrToFloat(fields[3]) < StrToFloat(autoFields[2]) then Result := Result or CFG_LINE_INVALID;
             if StrToFloat(fields[3]) > StrToFloat(autoFields[4]) then Result := Result or CFG_LINE_INVALID;
           end;
          if autoFields[1] = 'values:' then begin
            if Pos(fields[3], s) = 0 then Result := Result or CFG_LINE_INVALID;
          end;
           break;
        end;
      end;
      if i = AutoComleteList.Items.Count-2 then Result := Result or CFG_LINE_NO_NAME;

    end else if fields[0] = 'dma' then begin
      if fields[3] = 'NONE' then Result := Result or CFG_LINE_INACTIVE;
    end else if fields[0] = 'resource' then begin
      if fields[3] = 'NONE' then Result := Result or CFG_LINE_INACTIVE
      else if ActiveRcList.Items.Count > 0 then begin
        if ActiveRcList.Items.IndexOf(fields[3] + ': ' + fields[1] + ' ' + fields[2]) < 0 then begin
          if ActiveRcList.Items.IndexOf(fields[3] + ': ' + fields[1]) < 0 then begin
            if ActiveRcList.Items.IndexOf(fields[3] + ': FREE') < 0 then Result := Result or CFG_LINE_NO_ALLOC
            else Result := Result or CFG_LINE_INACTIVE;
          end;
        end;
      end;
    end;
  end;
end;

function TForm1.UartConnect(): Boolean;
var
  s: String;
  attempt: Integer;
begin
  if UartCombo.Text = '' then begin
    StatusLabel.Caption := 'No serial port selected!';
    Exit(False);
  end;
  s := '';
  StatusLabel.Caption := 'Connecting to ' + UartCombo.Text; StatusLabel.Repaint; {$IFDEF UNIX} Application.ProcessMessages; {$ENDIF}
  for attempt := 1 to 10 do begin
    Serial.Connect(UartCombo.Text);
    if Serial.LastError <> 0 then begin
      {$IFOPT D+}
      LogList.Items.Add('conn err: ' + IntToStr(Serial.LastError));
      {$ENDIF}
       Sleep(200);
       continue;
    end;
    Serial.Config(115200, 8, 'N', SB1, False, False);
    Serial.SendString('#' + #10);
    if Serial.CanReadEx(200) then begin
      s := Serial.Recvstring(1000);
      {$IFOPT D+}
      LogList.Items.Add('# recv: ' + s);
      LogList.Items.Add('# err: ' + IntToStr(Serial.LastError));
      {$ENDIF}
      if s = '#' then break;
    end;
    Serial.CloseSocket;
  end;
  if s <> '#' then begin;
     StatusLabel.Caption := 'Failed to connect to ' + UartCombo.Text;
     Exit(False);
  end;
  Result := True;
end;

procedure TForm1.GetRcByFeature(feature: String; RcList: TStrings);
var
  s: String;
  fields: TStringArray;
  featureRcPrefix: String;
  featureSetPrefix: String;
begin
  featureRcPrefix := Config.ReadString('feature_resources', feature, feature);
  featureSetPrefix := Config.ReadString('feature_settings', feature, LowerCase(feature)) + '_';
  RcList.Clear;
  for s in CurCfgList.Items do begin
    fields := s.Split(' ', TStringSplitOptions.ExcludeEmpty);
    if (fields[0] = 'resource') or (fields[0] = 'dma') then begin
      if Pos(featureRcPrefix, fields[1]) = 1 then begin
         RcList.Add(s);
      end;
    end else if fields[0] = 'set' then begin
      if Pos(featureSetPrefix, fields[1]) = 1 then begin
         RcList.Add(s);
      end;
    end;
  end;
end;

procedure TForm1.CurToDiffBtnClick(Sender: TObject);
begin
  DiffCfgList.Items := CurCfgList.Items;
end;

procedure TForm1.BeeperTabEnter(Sender: TObject);
var
  s: String;
  fields: TStringArray;
  feature: String;
  featureActive: Boolean;
  i: Integer;
begin
  BeeperList.Items.Clear;
  BeeperRcList.Items.Clear;
  BeeperRcList.Items.Clear;
  for s in CurCfgList.Items do begin
    fields := s.Split(' ', TStringSplitOptions.ExcludeEmpty);
    if fields[0] = 'beeper' then begin
        feature := fields[1];

        featureActive := False;
        if feature[1] = '-' then feature := Copy(feature, 2)
        else featureActive := True;

        i := BeeperList.Items.IndexOf(feature);
        if i >= 0 then BeeperList.Checked[i] := featureActive
        else begin
          BeeperList.Items.Add(feature);
          i := BeeperList.Items.IndexOf(feature);
          BeeperList.Checked[i] := featureActive;
        end;
    end;

    if fields[0] = 'resource' then begin
      feature := fields[1];
      if feature = 'BEEPER' then begin
         BeeperRcList.Items.Add(s);
      end;
    end;

    if fields[0] = 'set' then begin
      feature := fields[1];
      if Pos('beeper_', feature) = 1 then begin
         BeeperRcList.Items.Add(s);
      end;
    end;

  end;
end;

procedure TForm1.CurCfgListClick(Sender: TObject);
begin

end;

procedure TForm1.CfgListClick(Sender: TObject);
var
  ListBox: TListBox absolute Sender;
begin
  if ListBox.ItemIndex < 0 then Exit;
  CurCfgShowLine(ListBox.Items[ListBox.ItemIndex]);
end;

procedure TForm1.BeeperListSelectionChange(Sender: TObject; User: boolean);
var
  s: String;
  reason: String;
begin
  if not User then Exit;
  if BeeperList.ItemIndex < 0 then Exit;

  // Show correpsonding line in current config
  reason := BeeperList.Items[BeeperList.ItemIndex];
  if BeeperList.Checked[BeeperList.ItemIndex] then s := 'beeper ' + reason
  else s := 'beeper -' + reason;
  CurCfgShowLine(s);

  BeeperList.Hint := Config.ReadString('beeper_hints', BeeperList.Items[BeeperList.ItemIndex], '');
end;

procedure TForm1.BeeperListClickCheck(Sender: TObject);
var
  s: String;
  reason: String;
  reasonActive: Boolean;
  fields: TStringArray;
  i: Integer;
begin
  for i := CurCfgList.Items.Count-1 downto 0 do begin
    s := CurCfgList.Items[i];
    fields := s.Split(' ', TStringSplitOptions.ExcludeEmpty);
    if fields[0] = 'beeper' then begin
      reason := fields[1];
      reasonActive := False;
      if reason[1] = '-' then reason := Copy(reason, 2)
      else reasonActive := True;

      if BeeperList.Items[BeeperList.ItemIndex] = reason then begin
          //i := CurCfgList.Items.IndexOf(s);
          if reasonActive then CurCfgList.Items[i] := 'beeper -' + reason
          else CurCfgList.Items[i] := 'beeper ' + reason;
          CurCfgList.ItemIndex := i;
          break;
      end;
    end;
  end;
end;

procedure TForm1.CurCfgListDblClick(Sender: TObject);
begin
  if CurCfgList.ItemIndex < 0 then Exit;
  CurCfgList.Items[CurCfgList.ItemIndex] := InputBox('Edit', 'Edit line', CurCfgList.Items[CurCfgList.ItemIndex]);
  CfgLineSts[CurCfgList.ItemIndex] := CfgCalcSts(CurCfgList.ItemIndex);
end;

procedure TForm1.CurCfgListSelectionChange(Sender: TObject; User: boolean);
var
  s: String;
  fields: TStringArray;
  i: Integer;
begin
  if not User then Exit;
  if CurCfgList.ItemIndex < 0 then Exit;
  fields := CurCfgList.Items[CurCfgList.ItemIndex].Split(' ', TStringSplitOptions.ExcludeEmpty);
  if Length(fields) < 2 then Exit;

  s := '';
  for i := 0 to AutoComleteList.Items.Count-2 do begin
    if Pos(fields[1], AutoComleteList.Items[i]) = 1 then begin
       s := AutoComleteList.Items[i+1];
       fields := s.Split(' ', TStringSplitOptions.ExcludeEmpty);
       if fields[0] <> 'Allowed' then s := AutoComleteList.Items[i+2];
       break;
    end;
  end;
  CurCfgList.Hint := s;
end;

procedure TForm1.DiffToCurBtnClick(Sender: TObject);
begin
  CurCfgList.Items := DiffCfgList.Items;
end;

procedure TForm1.CfgListDblClick(Sender: TObject);
var
  ListBox: TListBox absolute Sender;
  s: String;
  localIndex: Integer;
  cfgIndex: Integer;
begin
  localIndex := ListBox.ItemIndex;
  if (localIndex < 0) Or (localIndex >= ListBox.Items.Count) then Exit;

  s := ListBox.Items[localIndex];
  cfgIndex := CurCfgList.Items.IndexOf(s);
  s := InputBox('Edit', 'Edit value:', s);
  CurCfgList.Items[cfgIndex] := s;
  CfgLineSts[cfgIndex] := CfgCalcSts(cfgIndex);
  ListBox.Items[localIndex] := s;
end;

procedure TForm1.UartWriteBtnClick(Sender: TObject);
var
  s: String;
  i: Integer;
  cmd: String;
begin
  if CurCfgList.Items.Count = 0 then begin
    StatusLabel.Caption := 'Nothing to write!';
    Exit;
  end;

  if not UartConnect() then Exit;

  StatusLabel.Caption := 'Writing current config to FC'; StatusLabel.Repaint; {$IFDEF UNIX} Application.ProcessMessages; {$ENDIF}
  for i := 0 to CurCfgList.Items.Count-1 do begin
    cmd := CurCfgList.Items[i];
    if (cmd = '') or (cmd[1] = '#') then continue;
    Serial.SendString(cmd + #10);
    Serial.SendString('#' + #10);
    while Serial.CanReadEx(1000) do begin
      s := Serial.Recvstring(1000);
      if s = '# #' then break;
      if Serial.LastError <> 0 then break;
    end;
    if s <> '# #' then begin;
       StatusLabel.Caption := 'Failed to write: ' + cmd;
       {$IFOPT D+}
       LogList.Items.Add('wr recv: ' + s);
       LogList.Items.Add('wr err: ' + IntToStr(Serial.LastError));
       {$ENDIF}
       ProgressBar.Position := 0;
       Serial.CloseSocket;
       Exit;
    end;
    ProgressBar.Position := Trunc(100*i / CurCfgList.Items.Count);
    ProgressBar.Repaint; {$IFDEF UNIX} Application.ProcessMessages; {$ENDIF}
  end;
  ProgressBar.Position := 0;

  StatusLabel.Caption := 'Saving FC config'; StatusLabel.Repaint; {$IFDEF UNIX} Application.ProcessMessages; {$ENDIF}
  Serial.SendString('save' + #10);
  Serial.CloseSocket; // This commands resets the FC, there is no response
  Sleep(1500);

  ActCfgList.Items := CurCfgList.Items;
  UartReadBtnClick(Sender); // Re-read configuration after a save
end;

procedure TForm1.FeaturesListClickCheck(Sender: TObject);
var
  s: String;
  feature: String;
  featureActive: Boolean;
  fields: TStringArray;
  i: Integer;
begin
  for i := CurCfgList.Items.Count-1 downto 0 do begin
    s := CurCfgList.Items[i];
    fields := s.Split(' ', TStringSplitOptions.ExcludeEmpty);
    if fields[0] = 'feature' then begin
      feature := fields[1];
      featureActive := False;
      if feature[1] = '-' then feature := Copy(feature, 2)
      else featureActive := True;

      if FeaturesList.Items[FeaturesList.ItemIndex] = feature then begin
          //i := CurCfgList.Items.IndexOf(s);
          if featureActive then CurCfgList.Items[i] := 'feature -' + feature
          else CurCfgList.Items[i] := 'feature '+feature;
          CurCfgList.ItemIndex := i;
          break;
      end;
    end;
  end;
end;

procedure TForm1.FeaturesListSelectionChange(Sender: TObject; User: boolean);
var
  s: String;
  feature: String;
begin
  if not User then Exit;
  if FeaturesList.ItemIndex < 0 then Exit;

  // Show correpsonding line in current config
  feature := FeaturesList.Items[FeaturesList.ItemIndex];
  if FeaturesList.Checked[FeaturesList.ItemIndex] then s := 'feature ' + feature
  else s := 'feature -' + feature;
  CurCfgShowLine(s);

  FeaturesList.Hint := Config.ReadString('feature_hints', FeaturesList.Items[FeaturesList.ItemIndex], '');

  GetRcByFeature(feature, FeatureRcList.Items);
end;

procedure TForm1.CfgListDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  ListBox: TListBox absolute Control;
  customColor: TColor;
  i: Integer;
begin

  customColor := clBlack;

  i := CurCfgList.Items.IndexOf(ListBox.Items[Index]);
  if(i >= 0) then begin
    if (CfgLineSts[i] and CFG_MASK_GRAY) <> 0 then customColor := clGray;
    if (CfgLineSts[i] and CFG_MASK_GREEN) <> 0 then customColor := clGreen;
    if (CfgLineSts[i] and CFG_MASK_BLUE) <> 0 then customColor := clBlue;
    if (CfgLineSts[i] and CFG_MASK_RED) <> 0 then customColor := clRed;
  end;

  if odSelected in State then begin
    ListBox.Canvas.Brush.Color := customColor;
  end else begin
    ListBox.Canvas.Font.Color := customColor;
  end;

  ListBox.Canvas.FillRect(ARect);
  ListBox.Canvas.TextRect(ARect, ARect.Left+2, ARect.Top, ListBox.Items[Index]);
end;

procedure TForm1.FeaturesTabEnter(Sender: TObject);
var
  s: String;
  fixFeatures: TStringArray;
  fields: TStringArray;
  feature: String;
  featureActive: Boolean;
  i: Integer;
begin
  FixFeaturesList.Items.Clear;
  fixFeatures := Config.ReadString('general', 'FIXED_FEATURES', '').Split(',');
  for s in fixFeatures do begin
    FixFeaturesList.Items.Add(s);
  end;

  FeaturesList.Items.Clear;
  for s in CurCfgList.Items do begin
    fields := s.Split(' ', TStringSplitOptions.ExcludeEmpty);
    if fields[0] = 'feature' then begin
        feature := fields[1];

        featureActive := False;
        if feature[1] = '-' then feature := Copy(feature, 2)
        else featureActive := True;

        i := FeaturesList.Items.IndexOf(feature);
        if i > 0 then FeaturesList.Checked[i] := featureActive
        else begin
          FeaturesList.Items.Add(feature);
          i := FeaturesList.Items.IndexOf(feature);
          FeaturesList.Checked[i] := featureActive;
        end;
    end;
  end;
end;

procedure TForm1.FileReadBtnClick(Sender: TObject);
var
  i: Integer;
begin
  if OpenDialog.Execute then begin
    if fileExists(OpenDialog.Filename) then begin
      FileNameEdit.Text := OpenDialog.FileName;
      CurCfgList.Items.LoadFromFile(FileNameEdit.Text);
      if ActCfgList.Items.Count = 0 then ActCfgList.Items := CurCfgList.Items;

      StatusLabel.Caption := 'Calculating config status'; StatusLabel.Repaint; {$IFDEF UNIX} Application.ProcessMessages; {$ENDIF}
      //setLength(CfgLineSts, CurCfgList.Items.Count);
      for i := 0 to CurCfgList.Items.Count-1 do begin
        CfgLineSts[i] := CfgCalcSts(i);
        ProgressBar.Position := Trunc(100*i / CurCfgList.Items.Count);
        ProgressBar.Repaint; {$IFDEF UNIX} Application.ProcessMessages; {$ENDIF}
      end;
      ProgressBar.Position := 0;

      FeaturesTabEnter(Sender);
      StatusLabel.Caption := 'Loaded ' + FileNameEdit.Text;
    end;
  end else begin
    StatusLabel.Caption := 'Loading aborted';
  end;
end;

procedure TForm1.FileWriteBtnClick(Sender: TObject);
var
  s: String;
  fields: TStringArray;
begin
  if CurCfgList.Items.Count < 1 then begin
    StatusLabel.Caption := 'Nothing to save!';
    Exit;
  end;

  // Try to guess a file name
  if FileNameEdit.Text <> '' then begin
    SaveDialog.FileName := FileNameEdit.Text;
  end else begin
    SaveDialog.FileName := 'config';
    for s in CurCfgList.Items do begin
      fields := s.Split(' ', TStringSplitOptions.ExcludeEmpty);
      if fields[0] = 'board_name' then SaveDialog.FileName := fields[1];
      if fields[0] = 'name' then begin
        if fields[1] <> '-' then SaveDialog.FileName := fields[1];
        break;
      end;
    end;
  end;

  if SaveDialog.Execute then
  begin
    FileNameEdit.Text := SaveDialog.FileName;
    CurCfgList.Items.SaveToFile(FileNameEdit.Text);
    StatusLabel.Caption := 'Saved ' + FileNameEdit.Text;
  end else begin
    StatusLabel.Caption := 'Saving aborted';
  end;
end;

procedure TForm1.FindButtonClick(Sender: TObject);
var
  i: Integer;
begin
  if CurCfgList.Items.Count < 2 then Exit;
  if CurCfgList.ItemIndex < 0 then CurCfgList.ItemIndex := 0;
  i := CurCfgList.ItemIndex + 1;
  while i <> CurCfgList.ItemIndex do begin
    if Pos(FindBox.Text, CurCfgList.Items[i]) > 0 then begin
      CurCfgList.ItemIndex := i;
      if FindBox.Items.IndexOf(FindBox.Text) = -1 then FindBox.Items.Add(FindBox.Text);
      Exit;
    end;
    i := i + 1;
    if i >= CurCfgList.Items.Count then i := 0;
  end;
end;

procedure TForm1.FixFeaturesListSelectionChange(Sender: TObject; User: boolean);
var
  feature: String;
begin
  if not User then Exit;
  if FixFeaturesList.ItemIndex < 0 then Exit;

  feature := FixFeaturesList.Items[FixFeaturesList.ItemIndex];
  FeaturesList.Hint := Config.ReadString('feature_hints', FixFeaturesList.Items[FixFeaturesList.ItemIndex], '');

  GetRcByFeature(feature, FeatureRcList.Items);
end;

procedure TForm1.LoadDefaultBtnClick(Sender: TObject);
begin
  if MessageDlg ('Confirm', 'Reset the FC config to default and load it?', mtConfirmation,
     [mbYes, mbNo],0) = mrYes
  then begin
    if not UartConnect() then Exit;

    StatusLabel.Caption := 'Resetting to defaults'; StatusLabel.Repaint; {$IFDEF UNIX} Application.ProcessMessages; {$ENDIF}
    Serial.SendString('defaults' + #10);
    Serial.CloseSocket; // This commands resets the FC, there is no response
    Sleep(1500);

    UartReadBtnClick(Sender); // Re-read configuration after a reset
  end;
end;

procedure TForm1.LogClearButtonClick(Sender: TObject);
begin
  LogList.Items.Clear;
end;

procedure TForm1.SerialListSelectionChange(Sender: TObject; User: boolean);
var
  s: String;
  i: Integer;
  fields: TStringArray;
  port: Integer;
  portFunction: String;
  portFnId: Integer;
begin
  if not User then Exit;
  if SerialList.ItemIndex < 0 then Exit;

  port := StrToInt(SerialList.Items[SerialList.ItemIndex]);

  SerialRcList.Items.Clear;
  for i := CurCfgList.Items.Count-1 downto 0 do begin
    s := CurCfgList.Items[i];
    fields := s.Split(' ', TStringSplitOptions.ExcludeEmpty);
    if fields[0] = 'resource' then begin
      if Pos('SERIAL', fields[1]) = 1 then begin
        if StrToInt(fields[2]) = port then begin
          SerialRcList.Items.Add(s);
        end;
      end;
    end;
    if fields[0] = 'serial' then begin
      if StrToInt(fields[1]) = port-1 then begin
        CurCfgList.ItemIndex := i;
        portFnId := StrToInt(fields[2]);
        if portFnId > 2 then portFnId := Trunc(Log2(portFnId+1))+1;
        SerialFnBox.ItemIndex := portFnId;
        portFunction := SerialFnBox.Items[SerialFnBox.ItemIndex];
        if Pos('MSP', portFunction) = 1 then SerialBaudBox.Text := fields[3]
        else if Pos('GPS', portFunction) = 1 then SerialBaudBox.Text := fields[4]
        else if Pos('TELEMETRY', portFunction) = 1 then SerialBaudBox.Text := fields[5]
        else if Pos('BLACKBOX', portFunction) = 1 then SerialBaudBox.Text := fields[6]
        else SerialBaudBox.Text := 'NONE';
      end;
    end;
  end;
end;

procedure TForm1.SerialTabEnter(Sender: TObject);
var
  s: String;
  fields: TStringArray;
  port: Integer;
begin
  SerialList.Items.Clear;
  for s in CurCfgList.Items do begin
    fields := s.Split(' ', TStringSplitOptions.ExcludeEmpty);
    if fields[0] = 'serial' then begin
        port := StrToInt(fields[1]) + 1;
        SerialList.Items.Add(IntToStr(port));
    end;
  end;

  // Load port functions from the config file
  fields := Config.ReadString('general', 'SERIAL_FUNCTIONS', '').Split(',');
  SerialFnBox.Items.Clear();
  for s in fields do begin
    SerialFnBox.Items.Add(s);
  end;

  // Load port baudrates from the config file
  SerialFnBox.ItemIndex := 0;
  fields := Config.ReadString('general', 'SERIAL_BAUDRATES', '').Split(',');
  SerialBaudBox.Items.Clear();
  for s in fields do begin
    SerialBaudBox.Items.Add(s);
  end;
  SerialBaudBox.ItemIndex := 4;
end;

procedure TForm1.UartComboClick(Sender: TObject);
var
  s: String;
  ports: TStringArray;
  index: Integer;
begin
  s := GetSerialPortNames;
  ports := s.Split(', ', TStringSplitOptions.ExcludeEmpty);

  for index := 0 to Length(ports)-1 do begin
    if UartCombo.Items.Count <> Length(ports) then begin
      UartCombo.Items.Clear;
      UartCombo.Items.AddStrings(ports);
      break;
    end;
    if UartCombo.Items[index] <> ports[index] then begin
      UartCombo.Items.Clear;
      UartCombo.Items.AddStrings(ports);
      break;
    end;
  end;

  if UartCombo.Items.IndexOf(UartCombo.Text) = -1 then UartCombo.Text := UartCombo.Items[0];
end;

procedure TForm1.UartReadBtnClick(Sender: TObject);
var
  s: String;
  i: Integer;
begin
  if not UartConnect() then Exit;

  StatusLabel.Caption := 'Reading config diff'; StatusLabel.Repaint; {$IFDEF UNIX} Application.ProcessMessages; {$ENDIF}
  Serial.SendString('diff' + #10);
  Serial.SendString('#' + #10);
  DiffCfgList.Items.Clear;
  while Serial.CanReadEx(1000) do begin
    s := Serial.Recvstring(1000);
    if s = '# #' then break;
    if Serial.LastError <> 0 then break;
    DiffCfgList.Items.Add(s);
  end;
  if s <> '# #' then begin;
     StatusLabel.Caption := 'Failed read diff config from FC on ' + UartCombo.Text;
      {$IFOPT D+}
      LogList.Items.Add('diff recv: ' + s);
      LogList.Items.Add('diff err: ' + IntToStr(Serial.LastError));
      {$ENDIF}
     Serial.CloseSocket;
     Exit;
  end;

  StatusLabel.Caption := 'Reading config dump'; StatusLabel.Repaint; {$IFDEF UNIX} Application.ProcessMessages; {$ENDIF}
  Serial.SendString('dump' + #10);
  Serial.SendString('#' + #10);
  CurCfgList.Items.Clear;
  while Serial.CanReadEx(1000) do begin
    s := Serial.Recvstring(1000);
    if s = '# #' then break;
    if Serial.LastError <> 0 then break;
    CurCfgList.Items.Add(s);
  end;
  if s <> '# #' then begin;
     StatusLabel.Caption := 'Failed read config dump from FC on ' + UartCombo.Text;
     {$IFOPT D+}
     LogList.Items.Add('dump recv: ' + s);
     LogList.Items.Add('dump err: ' + IntToStr(Serial.LastError));
     {$ENDIF}
     Serial.CloseSocket;
     Exit;
  end;

  StatusLabel.Caption := 'Reading active resources'; StatusLabel.Repaint; {$IFDEF UNIX} Application.ProcessMessages; {$ENDIF}
  Serial.SendString('resource show' + #10);
  Serial.SendString('#' + #10);
  ActiveRcList.Items.Clear;
  while Serial.CanReadEx(1000) do begin
    s := Serial.Recvstring(1000);
    if s = '# #' then break;
    if Serial.LastError <> 0 then break;
    ActiveRcList.Items.Add(s);
  end;
  if s <> '# #' then begin;
    StatusLabel.Caption := 'Failed read active resources from FC on ' + UartCombo.Text;
    {$IFOPT D+}
    LogList.Items.Add('rc recv: ' + s);
    LogList.Items.Add('rc err: ' + IntToStr(Serial.LastError));
    {$ENDIF}
    Serial.CloseSocket;
    Exit;
  end;

  StatusLabel.Caption := 'Reading autocomplete data'; StatusLabel.Repaint; {$IFDEF UNIX} Application.ProcessMessages; {$ENDIF}
  Serial.SendString('get' + #10);
  Serial.SendString('#' + #10);
  AutoComleteList.Items.Clear;
  while Serial.CanReadEx(1000) do begin
    s := Serial.Recvstring(1000);
    if s = '# #' then break;
    if Serial.LastError <> 0 then break;
    AutoComleteList.Items.Add(s);
  end;
  if s <> '# #' then begin;
     StatusLabel.Caption := 'Failed read autocomplete data from FC on ' + UartCombo.Text;
     {$IFOPT D+}
     LogList.Items.Add('get recv: ' + s);
     LogList.Items.Add('get err: ' + IntToStr(Serial.LastError));
     {$ENDIF}
     Serial.CloseSocket;
     Exit;
  end;

  StatusLabel.Caption := 'Calculating config status'; StatusLabel.Repaint; {$IFDEF UNIX} Application.ProcessMessages; {$ENDIF}
  ActCfgList.Items := CurCfgList.Items;
  //setLength(CfgLineSts, CurCfgList.Items.Count);
  for i := 0 to CurCfgList.Items.Count-1 do begin
    CfgLineSts[i] := CfgCalcSts(i);
    ProgressBar.Position := Trunc(100*i / CurCfgList.Items.Count);
    ProgressBar.Repaint; {$IFDEF UNIX} Application.ProcessMessages; {$ENDIF}
  end;
  ProgressBar.Position := 0;

  Serial.CloseSocket;
  StatusLabel.Caption := 'Received active config from FC on ' + UartCombo.Text;
  DetailsTab.ActivePage := FeaturesTab;
  FeaturesTab.Repaint;
  CurCfgList.Repaint;
end;

end.

