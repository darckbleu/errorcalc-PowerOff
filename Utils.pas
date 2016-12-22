{****************************************************************************************}
{                                       PowerOff                                         }
{                                   ErrorSoft(c) 2016                                    }
{                                                                                        }
{ This is my first public project using FireMonkey technology.                           }
{ This can be useful utilite or some of the sources, such as FontSizeForBox function.    }
{                                                                                        }
{ Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License }
{****************************************************************************************}
unit Utils;

interface

uses
  System.Types, FMX.Types, FMX.Graphics, FMX.TextLayout, System.Math, System.SysUtils, FMX.Controls, System.UITypes,
  FMX.StdCtrls;

const
  cMaxFontSize = 512;
type
  TLineKind = (Up, Down, Left, Right, Both);

function IsRu: Boolean;
function CalcTextSize(Text: string; Font: TFont; Size: Single = 0): TSizeF;
function FontSizeForBox(Text: string; Font: TFont; Width, Height: Single; MaxFontSize: Single = cMaxFontSize): Integer;
function SecondsToString(Seconds: Integer): string;
procedure DrawTick(Control: TTrackBar; Offset: Single; PageSize: Single; DrawBounds: Boolean;
  LineKind: TLineKind; LineWidth, LineSpace: Single; Color: TAlphaColor);

implementation

function IsRu: Boolean;
begin
  Result := PreferredUILanguages.ToLower.IndexOf('ru') <> -1;
end;

function cHour: Char;
begin
  if IsRu then Result := '�' else Result := 'h';
end;

function cMinute: Char;
begin
  if IsRu then Result := '�' else Result := 'm';
end;

function cSecond: Char;
begin
  if IsRu then Result := '�' else Result := 's';
end;

function CalcTextSize(Text: string; Font: TFont; Size: Single = 0): TSizeF;
var
  TextLayout: TTextLayout;
begin
  TextLayout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    TextLayout.BeginUpdate;
    try
      TextLayout.Text := Text;
      TextLayout.MaxSize := TPointF.Create(9999, 9999);
      TextLayout.Font.Assign(Font);
      if not SameValue(0, Size) then
      begin
        TextLayout.Font.Size := Size;
      end;
      TextLayout.WordWrap := False;
      TextLayout.Trimming := TTextTrimming.None;
      TextLayout.HorizontalAlign := TTextAlign.Leading;
      TextLayout.VerticalAlign := TTextAlign.Leading;
    finally
      TextLayout.EndUpdate;
    end;

    Result.Width := TextLayout.Width;
    Result.Height := TextLayout.Height;
  finally
    TextLayout.Free;
  end;
end;

function FontSizeForBox(Text: string; Font: TFont; Width, Height: Single; MaxFontSize: Single = cMaxFontSize): Integer;
var
  Size, Max, Min, MaxIterations: Integer;
  Current: TSizeF;
begin
  Max := Trunc(MaxFontSize);
  Min := 0;

  MaxIterations := 20;
  repeat
    Size := (Max + Min) div 2;

    Current := CalcTextSize(Text, Font, Size);

    if ((Abs(Width - Current.Width) < 1) and (Width >= Current.Width)) and
      ((Abs(Height - Current.Height) < 1) and (Height >= Current.Height)) then
      break
    else
    if (Width < Current.Width) or (Height < Current.Height) then
      Max := Size
    else
      Min := Size;

    Dec(MaxIterations);
  until MaxIterations = 0;

  Result := Size;
end;

function SecondsToString(Seconds: Integer): string;
var
  n: Integer;
begin
  Result := '';

  if Seconds >= 60 * 60 then
  begin
    n := Seconds div (60 * 60);
    Result := Result + n.toString + cHour + ' ';
  end;

  if Seconds >= 60 then
  begin
    n := (Seconds div 60) mod 60;
    if n <= 9 then
      Result := Result + '0';
    Result := Result + n.toString + cMinute + ' ';
  end;

  n := Seconds mod 60;
  if n <= 9 then
    Result := Result + '0';
  Result := Result + n.toString + cSecond + ' ';
end;

type
  THTrackBar = class(TTrackBar) end;

procedure DrawTick(Control: TTrackBar; Offset: Single; PageSize: Single; DrawBounds: Boolean;
  LineKind: TLineKind; LineWidth, LineSpace: Single; Color: TAlphaColor);
var
  Obj: TFmxObject;
  Cnt: TControl;
  L: TPointF;
  Coord, RealCoord: Single;

  function GetCoord(Value: Single): Single;
  // var
  //   Crutch: Integer;
  begin
    // Crutch := IfThen(SameValue(Value, Control.Min) or SameValue(Value, Control.Max), 0, 0);
    if Control.Orientation = TOrientation.Horizontal then
      Result := Ceil(THTrackBar(Control).GetThumbRect(Value).CenterPoint.X)//  + Crutch
    else
      Result := Ceil(THTrackBar(Control).GetThumbRect(Value).CenterPoint.Y);//  + Crutch;
  end;

  procedure DrawLine(Coord: Single);
  begin
    if Control.Orientation = TOrientation.Horizontal then
    begin
      if (SameValue(LineSpace, 0)) and (LineKind = TLineKind.Both) then
      begin
        Control.Canvas.DrawLine(
          PointF(Coord + 0.5, L.Y + Trunc(Cnt.Height / 2) - LineWidth + 0.5),
          PointF(Coord + 0.5, L.Y + Trunc(Cnt.Height / 2) + LineWidth - 0.5), 1)
      end else
      begin
        if (LineKind = TLineKind.Down) or (LineKind = TLineKind.Both) then
          Control.Canvas.DrawLine(
            PointF(Coord + 0.5, L.Y + Trunc(Cnt.Height / 2) + LineSpace + 0.5),
            PointF(Coord + 0.5, L.Y + Trunc(Cnt.Height / 2) + LineSpace + LineWidth - 0.5), 1);
        if (LineKind = TLineKind.Up) or (LineKind = TLineKind.Both) then
          Control.Canvas.DrawLine(
            PointF(Coord + 0.5, L.Y + Trunc(Cnt.Height / 2) - LineSpace - 0.5),
            PointF(Coord + 0.5, L.Y + Trunc(Cnt.Height / 2) - LineSpace - LineWidth + 0.5), 1);
      end;
    end else
    begin
      if (SameValue(LineSpace, 0)) and (LineKind = TLineKind.Both) then
      begin
        Control.Canvas.DrawLine(
          PointF(L.X + Trunc(Cnt.Width / 2) - LineWidth + 0.5, Coord + 0.5),
          PointF(L.X + Trunc(Cnt.Width / 2) + LineWidth - 0.5, Coord + 0.5), 1)
      end else
      begin
        if (LineKind = TLineKind.Right) or (LineKind = TLineKind.Both) then
          Control.Canvas.DrawLine(
            PointF(L.X + Trunc(Cnt.Width / 2) + LineWidth + 0.5, Coord + 0.5),
            PointF(L.X + Trunc(Cnt.Width / 2) + LineWidth + LineWidth - 0.5, Coord + 0.5), 1);
        if (LineKind = TLineKind.Left) or (LineKind = TLineKind.Both) then
          Control.Canvas.DrawLine(
            PointF(L.X + Trunc(Cnt.Width / 2) - LineWidth - 0.5, Coord + 0.5),
            PointF(L.X + Trunc(Cnt.Width / 2) - LineWidth - LineWidth + 0.5, Coord + 0.5), 1);
      end;
    end;
  end;

begin
  if Control.Orientation = TOrientation.Horizontal then
    Obj := Control.FindStyleResource('htrack')
  else
    Obj := Control.FindStyleResource('vtrack');

  if Obj = nil then
    Exit;

  Cnt := Obj.FindStyleResource('background') as TControl;
  if Cnt = nil then
    Exit;

  Control.Canvas.Stroke.Thickness := 1;
  Control.Canvas.Stroke.Kind := TBrushKind.Solid;
  Control.Canvas.Stroke.Color := Color;

//  if Control.Orientation = TOrientation.Horizontal then
//  begin
  L := Cnt.LocalToAbsolute(PointF(0, 0)) - Control.LocalToAbsolute(PointF(0, 0));
  if DrawBounds and not SameValue(Offset, 0.0) then
    DrawLine(GetCoord(Control.Min));

  Coord := Offset + Control.Min;
  while Coord <= Control.Max - Control.Min do
  begin
    if (Coord >= Control.Min) and (Coord <= Control.Max) then
    begin
      RealCoord := GetCoord(Coord);
      DrawLine(RealCoord);
    end;
    Coord := Coord + PageSize;
  end;

  if DrawBounds and not SameValue(GetCoord(Control.Max), GetCoord(Coord - PageSize)) then
    DrawLine(GetCoord(Control.Max));
end;

end.
