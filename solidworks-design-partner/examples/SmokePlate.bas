Attribute VB_Name = "SmokePlateModule"
Option Explicit

' Original synthetic smoke fixture; not a user's measured component.
' Import this module into a genuine SOLIDWORKS VBA macro project on Windows.
' Source reviewed against published API signatures; NOT compiled or run here.
' Configure full Windows paths and the localized plane name before running.
Private Const TEMPLATE_PATH As String = ""
Private Const OUTPUT_PATH As String = ""
Private Const SKETCH_PLANE As String = "Front Plane"
Private Const LENGTH_MM As Double = 80#
Private Const WIDTH_MM As Double = 40#
Private Const THICKNESS_MM As Double = 3#
Private Const MM_TO_M As Double = 0.001
Private Const DOC_PART As Long = 1
Private Const END_BLIND As Long = 0
Private Const START_SKETCH_PLANE As Long = 0
Private Const SOLID_BODY As Long = 0
Private Const SAVE_CURRENT_VERSION As Long = 0
Private Const SAVE_SILENT As Long = 1

Sub main()
    Dim swApp As Object, swModel As Object, activeModel As Object
    Dim sk As Object, skFeature As Object, boss As Object
    Dim segments As Variant, bodies As Variant
    Dim errors As Long, warnings As Long, featureCode As Long
    Dim featureWarning As Boolean, ok As Boolean
    Dim stage As String, createdTitle As String, parentFolder As String
    Dim savedErrorNumber As Long, savedErrorDescription As String

    On Error GoTo Failed
    stage = "preflight paths"
    RequireAbsoluteFile TEMPLATE_PATH, ".prtdot"
    RequireAbsoluteFile OUTPUT_PATH, ".sldprt"
    If Not PathExists(TEMPLATE_PATH) Then Err.Raise vbObjectError + 2101, , "Part template does not exist."
    If PathExists(OUTPUT_PATH) Then Err.Raise vbObjectError + 2102, , "Output already exists; choose a fresh filename. No model was created."
    parentFolder = Left$(OUTPUT_PATH, InStrRev(OUTPUT_PATH, "\") - 1)
    ' Preserve a drive root: C:\plate.SLDPRT has parent C:\, not C:.
    If Len(parentFolder) = 2 And Mid$(parentFolder, 2, 1) = ":" Then parentFolder = parentFolder & "\"
    If (GetAttr(parentFolder) And vbDirectory) = 0 Then Err.Raise vbObjectError + 2103, , "Output parent is not a directory."
    If LENGTH_MM <= 0 Or WIDTH_MM <= 0 Or THICKNESS_MM <= 0 Then Err.Raise vbObjectError + 2104, , "All fixture dimensions must be positive mm values."

    stage = "connect to the host SOLIDWORKS instance"
    Set swApp = Application.SldWorks
    If swApp Is Nothing Then Err.Raise vbObjectError + 2105, , "Run inside the intended Windows SOLIDWORKS VBA host."
    Debug.Print "SmokePlate host revision: " & swApp.RevisionNumber

    stage = "create a NEW part"
    Set swModel = swApp.NewDocument(TEMPLATE_PATH, 0, 0#, 0#)
    If swModel Is Nothing Then Err.Raise vbObjectError + 2106, , "NewDocument returned no document. Check template/version."
    createdTitle = swModel.GetTitle
    If swModel.GetType <> DOC_PART Then Err.Raise vbObjectError + 2107, , "Template did not produce a part."
    Set activeModel = swApp.ActiveDoc
    If activeModel Is Nothing Then Err.Raise vbObjectError + 2108, , "No active document after NewDocument."
    If Not (activeModel Is swModel) Then Err.Raise vbObjectError + 2109, , "Active document changed. Stop and inspect."

    stage = "select configured plane and open sketch"
    swModel.ClearSelection2 True
    ok = swModel.Extension.SelectByID2(SKETCH_PLANE, "PLANE", 0#, 0#, 0#, False, 0, Nothing, 0)
    If Not ok Then Err.Raise vbObjectError + 2110, , "Plane selection failed; configure the exact localized plane name."
    swModel.SketchManager.InsertSketch True
    Set sk = swModel.GetActiveSketch2
    If sk Is Nothing Then Err.Raise vbObjectError + 2111, , "No active sketch."
    Set skFeature = FindSketchFeature(swModel, sk)
    If skFeature Is Nothing Then Err.Raise vbObjectError + 2112, , "No sketch feature."

    stage = "create rectangle (explicit mm to meters)"
    segments = swModel.SketchManager.CreateCornerRectangle(0#, 0#, 0#, LENGTH_MM * MM_TO_M, WIDTH_MM * MM_TO_M, 0#)
    If Not IsArray(segments) Then Err.Raise vbObjectError + 2113, , "Rectangle returned no segment array."
    If UBound(segments) - LBound(segments) + 1 <> 4 Then Err.Raise vbObjectError + 2114, , "Rectangle did not return four edges."
    swModel.SketchManager.InsertSketch True
    Set sk = swModel.GetActiveSketch2
    If Not sk Is Nothing Then Err.Raise vbObjectError + 2115, , "Sketch did not close."
    skFeature.Name = "SmokePlateProfile"

    stage = "select the created sketch and extrude"
    swModel.ClearSelection2 True
    ok = skFeature.Select2(False, 0)
    If Not ok Then Err.Raise vbObjectError + 2116, , "Created sketch could not be selected."
    Set boss = swModel.FeatureManager.FeatureExtrusion3( _
        True, False, False, END_BLIND, END_BLIND, _
        THICKNESS_MM * MM_TO_M, 0#, False, False, False, False, _
        0#, 0#, False, False, False, False, True, False, True, _
        START_SKETCH_PLANE, 0#, False)
    If boss Is Nothing Then Err.Raise vbObjectError + 2117, , "FeatureExtrusion3 returned no feature."
    boss.Name = "SmokePlateExtrusion"

    stage = "rebuild and inspect feature/body results"
    swModel.ClearSelection2 True
    ok = swModel.ForceRebuild3(False)
    If Not ok Then Err.Raise vbObjectError + 2118, , "Rebuild returned failure."
    featureCode = boss.GetErrorCode2(featureWarning)
    If featureCode <> 0 Then Err.Raise vbObjectError + 2119, , "Extrusion feature code=" & featureCode & "; IsWarning=" & featureWarning
    featureCode = skFeature.GetErrorCode2(featureWarning)
    If featureCode <> 0 Then Err.Raise vbObjectError + 2120, , "Sketch feature code=" & featureCode & "; IsWarning=" & featureWarning
    bodies = swModel.GetBodies2(SOLID_BODY, False)
    If Not IsArray(bodies) Then Err.Raise vbObjectError + 2121, , "No solid body array."
    If UBound(bodies) - LBound(bodies) + 1 <> 1 Then Err.Raise vbObjectError + 2122, , "Expected exactly one solid body."

    stage = "save NEW native part"
    Set activeModel = swApp.ActiveDoc
    If activeModel Is Nothing Then Err.Raise vbObjectError + 2123, , "No active document before save."
    If Not (activeModel Is swModel) Then Err.Raise vbObjectError + 2124, , "Active document changed before save."
    ' SaveAs can overwrite; repeat collision guard immediately before saving.
    If PathExists(OUTPUT_PATH) Then Err.Raise vbObjectError + 2125, , "Output appeared during modeling; refusing to overwrite."
    swModel.ClearSelection2 True
    ok = swModel.Extension.SaveAs3(OUTPUT_PATH, SAVE_CURRENT_VERSION, SAVE_SILENT, Nothing, Nothing, errors, warnings)
    Debug.Print "SaveAs3 result=" & ok & "; errors=" & errors & "; warnings=" & warnings
    If Not ok Or errors <> 0 Then Err.Raise vbObjectError + 2126, , "Save failed; error bitmask=" & errors & ", warning bitmask=" & warnings
    If Not PathExists(OUTPUT_PATH) Then Err.Raise vbObjectError + 2127, , "Save returned success but output is missing."
    If FileLen(OUTPUT_PATH) = 0 Then Err.Raise vbObjectError + 2128, , "Output file is empty."
    If StrComp(swModel.GetPathName, OUTPUT_PATH, vbTextCompare) <> 0 Then Err.Raise vbObjectError + 2129, , "Document path does not match requested output."
    MsgBox "Native save checks passed: " & OUTPUT_PATH & vbCrLf & _
        "Save warning bitmask: " & warnings & vbCrLf & _
        "Still verify sketch/solid dimensions (" & LENGTH_MM & " x " & WIDTH_MM & " x " & THICKNESS_MM & " mm), " & _
        "feature editability, and reopen/rebuild. No export or physical test performed.", vbInformation, "SmokePlate"
    Exit Sub

Failed:
    savedErrorNumber = Err.Number
    savedErrorDescription = Err.Description
    Debug.Print "SmokePlate FAILED at " & stage & ": " & savedErrorNumber & " " & savedErrorDescription
    MsgBox "Stopped at: " & stage & vbCrLf & _
        CStr(savedErrorNumber) & ": " & savedErrorDescription & vbCrLf & _
        "Created document: " & createdTitle & vbCrLf & _
        "Document left open; save state may be unsaved or uncertain. Inspect it and the output path. Existing documents were not intentionally edited or closed. Do not blindly rerun after a timeout.", vbExclamation, "SmokePlate stopped"
End Sub

Private Sub RequireAbsoluteFile(ByVal filePath As String, ByVal suffix As String)
    If Len(filePath) < 4 Then Err.Raise vbObjectError + 2130, , "Configure full Windows template and output paths."
    If Not (Mid$(filePath, 2, 2) = ":\" Or Left$(filePath, 2) = "\\") Then Err.Raise vbObjectError + 2131, , "Path must be absolute on Windows."
    If LCase$(Right$(filePath, Len(suffix))) <> suffix Then Err.Raise vbObjectError + 2132, , "Wrong extension; expected " & suffix
End Sub

Private Function PathExists(ByVal filePath As String) As Boolean
    ' Errors (including unavailable/network paths) propagate to the main handler.
    PathExists = (Len(Dir$(filePath, vbNormal Or vbReadOnly Or vbHidden Or vbSystem Or vbArchive Or vbDirectory)) > 0)
End Function

Private Function FindSketchFeature(ByVal model As Object, ByVal targetSketch As Object) As Object
    Dim feature As Object, candidate As Object
    Set feature = model.FirstFeature
    Do While Not feature Is Nothing
        If feature.GetTypeName2 = "ProfileFeature" Then
            Set candidate = feature.GetSpecificFeature2
            If Not candidate Is Nothing Then
                If candidate Is targetSketch Then
                    Set FindSketchFeature = feature
                    Exit Function
                End If
            End If
        End If
        Set feature = feature.GetNextFeature
    Loop
    Set FindSketchFeature = Nothing
End Function
