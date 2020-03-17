unit uFDDataSetEditor;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Vcl.Dialogs,
  DesignIntf,
  DesignEditors,
  DB,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;
type

  TFDDataSetEditor = class(TComponentEditor)
  private
    FOldEditor: TComponentEditor;
  protected
    function DataSet: TFDQuery;
  public
    constructor Create(
      AComponent: TComponent;
      ADesigner: IDesigner); override;
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;

    procedure SetFieldsProperties;
  end;

procedure Register;

implementation



var
  PrevEditorClass: TComponentEditorClass = nil;

constructor TFDDataSetEditor.Create(
  AComponent: TComponent;
  ADesigner: IDesigner);
begin
  inherited Create(AComponent, ADesigner);
  if Assigned(PrevEditorClass) then
  begin
    FOldEditor := TComponentEditor(PrevEditorClass.Create(AComponent,
      ADesigner));
  end;
end;

function TFDDataSetEditor.DataSet: TFDQuery;
begin
  Result := GetComponent as TFDQuery;
end;

procedure TFDDataSetEditor.ExecuteVerb(Index: Integer);
begin
  IF (Index = 0) THEN
  BEGIN
    SetFieldsProperties
  END
  ELSE
  BEGIN
    IF Assigned(FOldEditor) THEN
    BEGIN
      FOldEditor.ExecuteVerb(Index - 1);
    END;
  END;
end;

function TFDDataSetEditor.GetVerb(Index: Integer): string;
begin
  if (Index = 0) then
  begin
    Result := '&Get Fields Properties...'
  end
  else
  begin
    if Assigned(FOldEditor) then
    begin
      Result := FOldEditor.GetVerb(Index - 1);
    end;
  end;
end;

function TFDDataSetEditor.GetVerbCount: Integer;
begin
  Result := 1;
  if Assigned(FOldEditor) then
  begin
    Inc(
      Result,
      FOldEditor.GetVerbCount);
  end;
end;

Procedure Register;
var
  FDQ: TFDQuery;
  Editor: IComponentEditor;
begin
  FDQ := TFDQuery.Create(nil);
  Try
    Editor := GetComponentEditor(
      FDQ,
      nil);
    if Assigned(Editor) then
    begin
      PrevEditorClass := TComponentEditorClass((Editor as TObject).ClassType);
    end;
  finally
    Editor := nil;
    FDQ.Free;
  end;
  RegisterComponentEditor(
    TFDQuery,
    TFDDataSetEditor);
end;

procedure TFDDataSetEditor.SetFieldsProperties;
const
  R = 'SELECT TABLE_NAME , FIELD_NAME ' +
    ', DISPLAY_LABEL , DISPLAY_FORMAT ,EDIT_FORMAT, VISIBLE FROM FD$FILED_DEFS '
    + 'WHERE TABLE_NAME = :TABLE_NAME AND FIELD_NAME = :FIELD_NAME';
var
  aFieldName: string;
  aDisplayLabel: string;
  aDisplayFormat: string;
  aEditFormat: string;
  aVisible: Integer;
  I: Integer;
  FieldDesc: TFDDatSColumn;
  aTableName: string;
  FQuery: TFDQuery;
  OldActive: Boolean;
begin
  try
    OldActive := DataSet.Active;
    DataSet.Active := True;
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
      Exit;
    end;

  end;

  FQuery := TFDQuery.Create(DataSet.Connection);
  try
    FQuery.Connection := DataSet.Connection;
    FQuery.Transaction := DataSet.Transaction;
    FQuery.UpdateTransaction := DataSet.UpdateTransaction;
    FQuery.SQL.Add(R);

    for I := 0 to DataSet.Fields.Count - 1 do
    begin
      FieldDesc := TFDDatSColumn(DataSet.GetFieldColumn(DataSet.Fields[I]));
      aFieldName := FieldDesc.Name;
      aTableName := FieldDesc.OriginTabName;
      FQuery.Close;
      FQuery.Params[0].AsString := aTableName;
      FQuery.Params[1].AsString := aFieldName;
      FQuery.Open;

      if FQuery.RecordCount > 0 then
      begin
        aDisplayLabel := Trim(FQuery.FieldByName('DISPLAY_LABEL').AsString);
        aDisplayFormat := Trim(FQuery.FieldByName('DISPLAY_FORMAT').AsString);
        aEditFormat := Trim(FQuery.FieldByName('EDIT_FORMAT').AsString);
        aVisible := FQuery.FieldByName('VISIBLE').AsInteger;

        if aDisplayLabel <> '' then
        begin
          if (DataSet.Fields[I].DisplayLabel <> aDisplayLabel) and
            (DataSet.Fields[I].DisplayLabel = aFieldName) then
          begin
            DataSet.Fields[I].DisplayLabel := aDisplayLabel;
          end;
        end;
        if aDisplayFormat <> '' then
        begin
          if DataSet.Fields[I] is TNumericField then
            if TNumericField(DataSet.Fields[I]).DisplayFormat = '' then
              TNumericField(DataSet.Fields[I]).DisplayFormat := aDisplayFormat;
        end;
        if aEditFormat <> '' then
        begin
          if DataSet.Fields[I] is TNumericField then
            if TNumericField(DataSet.Fields[I]).EditFormat = '' then
              TNumericField(DataSet.Fields[I]).EditFormat := aEditFormat;
        end;
      end;

      DataSet.Fields[I].Visible := Boolean(aVisible);

    end;
    FQuery.Close;
  finally
    FQuery.Free;
    DataSet.Active := OldActive;
  end;

end;

end.
