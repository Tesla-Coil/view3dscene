unit V3DSceneShadows;

interface

uses GLWindow, VRMLGLScene, VectorMath, KambiSceneManager;

type
  { TKamSceneManager descendant that takes care of setting
    TKamSceneManager shadow volume properties, and modifies a little
    shadow volume rendering to work nicely with all view3dscene
    configurations (bump mapping, fill modes etc.) }
  TV3DShadowsSceneManager = class(TKamSceneManager)
  protected
    procedure InitShadowsProperties;
    procedure Render3D(TransparentGroup: TTransparentGroup; InShadow: boolean); override;
  end;

var
  MenuShadowsMenu: TMenu;

const
  DefaultShadowsPossibleWanted = true;

var
  { Whether user wants to try next time to initialize
    ShadowsPossibleCurrently = true.
    This can change during runtime, but will be applied only on restart. }
  ShadowsPossibleWanted: boolean = DefaultShadowsPossibleWanted;

  { Whether we managed to initialize OpenGL context with stencil buffer
    (and set projection to infinity and initialized ShadowVolumes instance).
    This can be true only if ShadowsPossibleWanted was initially true. }
  ShadowsPossibleCurrently: boolean = false;

  ShadowsOn: boolean = true;
  DrawShadowVolumes: boolean = false;

procedure ShadowsGLInit;
procedure ShadowsGLClose;

implementation

uses SysUtils, V3DSceneConfig, GL, KambiGLUtils, V3DSceneFillMode;

procedure ShadowsGLInit;
begin
  MenuShadowsMenu.Enabled := ShadowsPossibleCurrently;
end;

procedure ShadowsGLClose;
begin
end;

procedure TV3DShadowsSceneManager.InitShadowsProperties;
begin
  ShadowVolumesPossible := ShadowsPossibleCurrently;
  ShadowVolumes := ShadowsOn;
  ShadowVolumesDraw := DrawShadowVolumes;
end;

procedure TV3DShadowsSceneManager.Render3D(
  TransparentGroup: TTransparentGroup; InShadow: boolean);
var
  OldColor: TVector4Single;
begin
  if InShadow then
  begin
    { Thanks to using PureGeometryShadowedColor, shadow is visible
      even when Attributes.PureGeometry. }
    if MainScene.Attributes.PureGeometry then
    begin
      glPushAttrib(GL_CURRENT_BIT);
      glColorv(PureGeometryShadowedColor);
    end;

    { Thanks to changing BumpMappingLightDiffuseColor, shadow is visible
      even when bump mapping is at work. }
    OldColor := MainScene.BumpMappingLightDiffuseColor;
    MainScene.BumpMappingLightDiffuseColor := Black4Single;

    inherited;

    MainScene.BumpMappingLightDiffuseColor := OldColor;

    if MainScene.Attributes.PureGeometry then
      glPopAttrib;
  end else
    inherited;
end;

initialization
  ShadowsPossibleWanted := ConfigFile.GetValue(
    'video_options/shadows_possible_wanted', DefaultShadowsPossibleWanted);
finalization
  ConfigFile.SetDeleteValue('video_options/shadows_possible_wanted',
    ShadowsPossibleWanted, DefaultShadowsPossibleWanted);
end.
