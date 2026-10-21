<#
.SYNOPSIS
    PSColorStyle class for managing reusable color and style configurations

.DESCRIPTION
    A PSColorStyle holds the colors, styles and layout settings of a Write-ColorEX call, so
    they can be reused with -StyleProfile.

    - [PSColorStyle]::Default is the style -Default applies
    - [PSColorStyle]::Profiles holds named styles
    - Built-in profiles: Default, Error, Warning, Info, Success, Critical, Debug
    - ToWriteColorParams() returns the Write-ColorEX parameters a style sets, read from its
      properties on each call, so a change to a style applies to its next use
    - Clone() copies a style

    USAGE PATTERN:
    - Create custom styles with New-ColorStyle function
    - Access built-in profiles: [PSColorStyle]::Profiles['Error']
    - Set default style: $style.SetAsDefault()
    - Register profiles: $style.AddToProfiles()

.NOTES
    Author: Mark Newton
    License: MIT
    Requires: PowerShell 5.1 or later

    PSColorStyle is one .NET type for the whole process. The first import builds it with
    Reflection.Emit and every later import, in any runspace, takes the same type, so a style made
    in one runspace works in every other. Its properties, its constructors and the Default and
    Profiles it keeps are plain data. Each of its methods runs the functions below in the module
    of the runspace that calls it, so no method depends on the runspace that made the style or
    imported the module, which can be disposed while the others go on.

    Importing the module makes [PSColorStyle] usable in the session and creates the built-in
    profiles with InitializeDefaultProfiles().

.LINK
    https://github.com/MarkusMcNugen/PSWriteColorEX

.LINK
    New-ColorStyle

.LINK
    Set-ColorDefault

.EXAMPLE
    # Create and register a custom style
    $style = [PSColorStyle]::new("Header", "Cyan", $null)
    $style.Bold = $true
    $style.Underline = $true
    $style.HorizontalCenter = $true
    $style.AddToProfiles()

.EXAMPLE
    # Use a built-in profile
    $errorStyle = [PSColorStyle]::Profiles['Error']
    Write-ColorEX -Text "Failed!" -StyleProfile $errorStyle

.EXAMPLE
    # Clone and modify a profile
    $customError = [PSColorStyle]::Profiles['Error'].Clone()
    $customError.Name = "MyError"
    $customError.Italic = $true
#>

# PSColorStyle's properties in order, each with its type
$script:ColorStyleProperties = [ordered]@{
    Name               = [string]
    ForegroundColor    = [object]
    BackgroundColor    = [object]
    Gradient           = [object[]]
    Style              = [string[]]
    StartTab           = [int]
    StartSpaces        = [int]
    LinesBefore        = [int]
    LinesAfter         = [int]
    Bold               = [bool]
    Italic             = [bool]
    Underline          = [bool]
    Blink              = [bool]
    Faint              = [bool]
    CrossedOut         = [bool]
    DoubleUnderline    = [bool]
    Overline           = [bool]
    ShowTime           = [bool]
    NoNewLine          = [bool]
    HorizontalCenter   = [bool]
    AutoPad            = [int]
    PadLeft            = [bool]
    PadChar            = [char]
    BackgroundGradient = [object[]]
    GradientSpace      = [string]
    GradientHue        = [string]
    GradientEasing     = [string]
    GradientRepeat     = [string]
    GradientDirection  = [string]
    GradientSteps      = [int]
    Reverse            = [bool]
    UnderlineColor     = [object]
    UnderlineStyle     = [string]
    PadCenter          = [bool]
    Truncate           = [bool]
    Wrap               = [bool]
}

# PSColorStyle's methods: whether each is static and whether hidden, what it returns ('Self' for
# a PSColorStyle, $null for nothing) and its parameters in order
$script:ColorStyleMethods = @(
    [pscustomobject]@{ Name = 'Initialize'; Static = $false; Hidden = $true; Returns = $null; Parameters = [ordered]@{ name = [string]; foreground = [object]; background = [object] } }
    [pscustomobject]@{ Name = 'SetAsDefault'; Static = $false; Hidden = $false; Returns = $null; Parameters = [ordered]@{} }
    [pscustomobject]@{ Name = 'AddToProfiles'; Static = $false; Hidden = $false; Returns = $null; Parameters = [ordered]@{} }
    [pscustomobject]@{ Name = 'GetProfile'; Static = $true; Hidden = $false; Returns = 'Self'; Parameters = [ordered]@{ name = [string] } }
    [pscustomobject]@{ Name = 'InitializeDefaultProfiles'; Static = $true; Hidden = $false; Returns = $null; Parameters = [ordered]@{} }
    [pscustomobject]@{ Name = 'ToWriteColorParams'; Static = $false; Hidden = $false; Returns = [hashtable]; Parameters = [ordered]@{} }
    [pscustomobject]@{ Name = 'InvalidateCache'; Static = $false; Hidden = $true; Returns = $null; Parameters = [ordered]@{} }
    [pscustomobject]@{ Name = 'Clone'; Static = $false; Hidden = $false; Returns = 'Self'; Parameters = [ordered]@{} }
    [pscustomobject]@{ Name = 'IsGradient'; Static = $true; Hidden = $true; Returns = [bool]; Parameters = [ordered]@{ Value = [object[]] } }
    [pscustomobject]@{ Name = 'CopyValue'; Static = $true; Hidden = $true; Returns = [object]; Parameters = [ordered]@{ Value = [object] } }
)

# The layout of what Initialize-ColorStyleType emits beyond the tables above; part of the type's
# assembly name with them, so a module that emits a different type never takes this one
$script:ColorStyleLayout = 1

# The name a runspace's script block for PSColorStyle's methods is kept under in the process,
# followed by the runspace's id
$script:ColorStyleMemberKey = 'PSWriteColorEX.PSColorStyle.'

# The script block PSColorStyle's methods run in this runspace
$script:ColorStyleMember = {
    param([string] $Member, [object] $Style, [object[]] $Arguments)
    Invoke-ColorStyleMember -Member $Member -Style $Style -Arguments $Arguments
}

function Get-ColorStyleShape {
    <#
    .SYNOPSIS
    A hash of PSColorStyle's members and layout, which names the assembly the type is built in.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    $members = @("layout $script:ColorStyleLayout")
    foreach ($name in $script:ColorStyleProperties.Keys) {
        $members += "$name $($script:ColorStyleProperties[$name].FullName)"
    }
    foreach ($method in $script:ColorStyleMethods) {
        $parameters = foreach ($name in $method.Parameters.Keys) { "$name $($method.Parameters[$name].FullName)" }
        $members += "$($method.Name) $($method.Static) $($method.Hidden) $($method.Returns) $($parameters -join ',')"
    }
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hash = $sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($members -join "`n"))
    } finally {
        $sha.Dispose()
    }
    return -join ($hash[0..7] | ForEach-Object { $_.ToString('x2') })
}

function Get-ColorStyleType {
    <#
    .SYNOPSIS
    Returns this process's PSColorStyle type, building it the first time.

    .DESCRIPTION
    The type lives in an assembly named after the hash of its members, so every import of a
    module with the same members, in any runspace, takes the same type: the one [PSColorStyle]
    names already, or else the one an earlier import built, or else one built now. The first type
    of these members that [PSColorStyle] names stays named, so imports that build at the same
    moment all take the type that was named first; a type with other members, from another module
    or version, is replaced, as each import names its own.
    #>
    [CmdletBinding()]
    [OutputType([type])]
    param()

    $assemblyName = "PSWriteColorEX.PSColorStyle.$(Get-ColorStyleShape)"
    $accelerators = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
    $named = Get-ColorStyleAccelerator -AssemblyName $assemblyName
    if ($null -ne $named) {
        return $named
    }
    $built = $null
    foreach ($assembly in [System.AppDomain]::CurrentDomain.GetAssemblies()) {
        if ($null -eq $built -and $assembly.IsDynamic -and $assembly.GetName().Name -eq $assemblyName) {
            $built = $assembly.GetType('PSColorStyle')
        }
    }
    if ($null -eq $built) {
        $built = Initialize-ColorStyleType -AssemblyName $assemblyName
    }
    $named = Get-ColorStyleAccelerator -AssemblyName $assemblyName
    if ($null -ne $named) {
        return $named
    }
    $accelerators::Add('PSColorStyle', $built)
    return $built
}

function Get-ColorStyleAccelerator {
    <#
    .SYNOPSIS
    The type [PSColorStyle] names when it is one from the assembly named, or $null.
    #>
    [CmdletBinding()]
    [OutputType([type])]
    param([Parameter(Mandatory)][string] $AssemblyName)

    $named = ([psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators'))::Get
    if ($named.ContainsKey('PSColorStyle') -and $named['PSColorStyle'].Assembly.GetName().Name -eq $AssemblyName) {
        return $named['PSColorStyle']
    }
    return $null
}

function Add-ColorStyleProperty {
    <#
    .SYNOPSIS
    Adds a property to the type being built: a field, and the get and set methods that read and
    write it. Returns the field.
    #>
    [CmdletBinding()]
    [OutputType([System.Reflection.Emit.FieldBuilder])]
    param(
        [Parameter(Mandatory)][System.Reflection.Emit.TypeBuilder] $Type,
        [Parameter(Mandatory)][string] $Name,
        [Parameter(Mandatory)][type] $PropertyType,
        [switch] $Static
    )

    $op = [System.Reflection.Emit.OpCodes]
    $fieldAttributes = [System.Reflection.FieldAttributes]::Private
    $methodAttributes = [System.Reflection.MethodAttributes]'Public, HideBySig, SpecialName'
    $callingConvention = [System.Reflection.CallingConventions]::HasThis
    if ($Static) {
        $fieldAttributes = $fieldAttributes -bor [System.Reflection.FieldAttributes]::Static
        $methodAttributes = $methodAttributes -bor [System.Reflection.MethodAttributes]::Static
        $callingConvention = [System.Reflection.CallingConventions]::Standard
    }
    $field = $Type.DefineField("<$Name>k__BackingField", $PropertyType, $fieldAttributes)
    $property = $Type.DefineProperty($Name, [System.Reflection.PropertyAttributes]::None, $callingConvention, $PropertyType, [type[]]@())

    $getter = $Type.DefineMethod("get_$Name", $methodAttributes, $callingConvention, $PropertyType, [type[]]@())
    $il = $getter.GetILGenerator()
    if ($Static) {
        $il.Emit($op::Ldsfld, [System.Reflection.FieldInfo]$field)
    } else {
        $il.Emit($op::Ldarg_0)
        $il.Emit($op::Ldfld, [System.Reflection.FieldInfo]$field)
    }
    $il.Emit($op::Ret)

    $setter = $Type.DefineMethod("set_$Name", $methodAttributes, $callingConvention, [void], [type[]]@($PropertyType))
    $null = $setter.DefineParameter(1, [System.Reflection.ParameterAttributes]::None, 'value')
    $il = $setter.GetILGenerator()
    $il.Emit($op::Ldarg_0)
    if ($Static) {
        $il.Emit($op::Stsfld, [System.Reflection.FieldInfo]$field)
    } else {
        $il.Emit($op::Ldarg_1)
        $il.Emit($op::Stfld, [System.Reflection.FieldInfo]$field)
    }
    $il.Emit($op::Ret)

    $property.SetGetMethod($getter)
    $property.SetSetMethod($setter)
    return $field
}

function Initialize-ColorStyleType {
    <#
    .SYNOPSIS
    Builds the PSColorStyle type with Reflection.Emit, in a new assembly of the name given.

    .DESCRIPTION
    The properties and constructors are plain data. Each method puts its arguments in an array
    and hands them, with its own name and the style, to InvokeMember, which runs the script block
    the calling runspace's import registered under that runspace's id; the method converts what
    comes back to the type it returns. Enter and Leave count the imports that use the type.
    #>
    [CmdletBinding()]
    [OutputType([type])]
    param([Parameter(Mandatory)][string] $AssemblyName)

    $op = [System.Reflection.Emit.OpCodes]
    $assembly = [System.Reflection.Emit.AssemblyBuilder]::DefineDynamicAssembly(
        [System.Reflection.AssemblyName]::new($AssemblyName), [System.Reflection.Emit.AssemblyBuilderAccess]::Run)
    $type = $assembly.DefineDynamicModule($AssemblyName).DefineType(
        'PSColorStyle', [System.Reflection.TypeAttributes]'Public, Class, BeforeFieldInit', [object])

    $fields = @{}
    foreach ($name in $script:ColorStyleProperties.Keys) {
        $fields[$name] = Add-ColorStyleProperty -Type $type -Name $name -PropertyType $script:ColorStyleProperties[$name]
    }
    $null = Add-ColorStyleProperty -Type $type -Name 'Default' -PropertyType $type -Static
    $profiles = Add-ColorStyleProperty -Type $type -Name 'Profiles' -PropertyType ([hashtable]) -Static

    # Profiles starts as an empty table that compares names without regard to case, as @{} does
    $il = $type.DefineTypeInitializer().GetILGenerator()
    $il.Emit($op::Call, [System.StringComparer].GetProperty('CurrentCultureIgnoreCase').GetGetMethod())
    $il.Emit($op::Newobj, [hashtable].GetConstructor([type[]]@([System.Collections.IEqualityComparer])))
    $il.Emit($op::Stsfld, [System.Reflection.FieldInfo]$profiles)
    $il.Emit($op::Ret)

    # Each constructor sets what Initialize sets: the name and colors given, the name Custom and
    # the color Gray where none is given, an empty list of styles, a space to pad with and empty
    # gradient and underline settings
    $constructors = @(
        [ordered]@{}
        [ordered]@{ name = [string] }
        [ordered]@{ name = [string]; foreground = [object]; background = [object] }
    )
    foreach ($parameters in $constructors) {
        $constructor = $type.DefineConstructor([System.Reflection.MethodAttributes]'Public, HideBySig, SpecialName, RTSpecialName',
            [System.Reflection.CallingConventions]::Standard, [type[]]@($parameters.Values))
        $position = 1
        foreach ($parameter in $parameters.Keys) {
            $null = $constructor.DefineParameter($position, [System.Reflection.ParameterAttributes]::None, $parameter)
            $position++
        }
        $il = $constructor.GetILGenerator()
        $il.Emit($op::Ldarg_0)
        $il.Emit($op::Call, [object].GetConstructor([type[]]@()))
        $il.Emit($op::Ldarg_0)
        if ($parameters.Count -ge 1) { $il.Emit($op::Ldarg_1) } else { $il.Emit($op::Ldstr, 'Custom') }
        $il.Emit($op::Stfld, [System.Reflection.FieldInfo]$fields['Name'])
        $il.Emit($op::Ldarg_0)
        if ($parameters.Count -ge 3) { $il.Emit($op::Ldarg_2) } else { $il.Emit($op::Ldstr, 'Gray') }
        $il.Emit($op::Stfld, [System.Reflection.FieldInfo]$fields['ForegroundColor'])
        if ($parameters.Count -ge 3) {
            $il.Emit($op::Ldarg_0)
            $il.Emit($op::Ldarg_3)
            $il.Emit($op::Stfld, [System.Reflection.FieldInfo]$fields['BackgroundColor'])
        }
        $il.Emit($op::Ldarg_0)
        $il.Emit($op::Ldc_I4_0)
        $il.Emit($op::Newarr, [string])
        $il.Emit($op::Stfld, [System.Reflection.FieldInfo]$fields['Style'])
        $il.Emit($op::Ldarg_0)
        $il.Emit($op::Ldc_I4, [int][char]' ')
        $il.Emit($op::Stfld, [System.Reflection.FieldInfo]$fields['PadChar'])
        foreach ($name in 'GradientSpace', 'GradientHue', 'GradientEasing', 'GradientRepeat', 'GradientDirection', 'UnderlineStyle') {
            $il.Emit($op::Ldarg_0)
            $il.Emit($op::Ldstr, '')
            $il.Emit($op::Stfld, [System.Reflection.FieldInfo]$fields[$name])
        }
        $il.Emit($op::Ret)
    }

    # InvokeMember(name, style, arguments): the calling runspace's script block, found under its
    # id, run with the three; a runspace that has not imported the module has none
    $invoke = $type.DefineMethod('InvokeMember', [System.Reflection.MethodAttributes]'Private, Static, HideBySig',
        [System.Reflection.CallingConventions]::Standard, [object], [type[]]@([string], [object], [object[]]))
    $il = $invoke.GetILGenerator()
    $runspace = $il.DeclareLocal([runspace])
    $id = $il.DeclareLocal([guid])
    $handler = $il.DeclareLocal([scriptblock])
    $missing = $il.DefineLabel()
    $missingPop = $il.DefineLabel()
    $il.Emit($op::Call, [runspace].GetProperty('DefaultRunspace').GetGetMethod())
    $il.Emit($op::Stloc, $runspace)
    $il.Emit($op::Ldloc, $runspace)
    $il.Emit($op::Brfalse, $missing)
    $il.Emit($op::Call, [System.AppDomain].GetProperty('CurrentDomain').GetGetMethod())
    $il.Emit($op::Ldstr, $script:ColorStyleMemberKey)
    $il.Emit($op::Ldloc, $runspace)
    $il.Emit($op::Callvirt, [runspace].GetProperty('InstanceId').GetGetMethod())
    $il.Emit($op::Stloc, $id)
    $il.Emit($op::Ldloca, $id)
    $il.Emit($op::Call, [guid].GetMethod('ToString', [type[]]@()))
    $il.Emit($op::Call, [string].GetMethod('Concat', [type[]]@([string], [string])))
    $il.Emit($op::Callvirt, [System.AppDomain].GetMethod('GetData', [type[]]@([string])))
    $il.Emit($op::Isinst, [System.WeakReference])
    $il.Emit($op::Dup)
    $il.Emit($op::Brfalse, $missingPop)
    $il.Emit($op::Callvirt, [System.WeakReference].GetProperty('Target').GetGetMethod())
    $il.Emit($op::Isinst, [scriptblock])
    $il.Emit($op::Stloc, $handler)
    $il.Emit($op::Ldloc, $handler)
    $il.Emit($op::Brfalse, $missing)
    $il.Emit($op::Ldloc, $handler)
    $il.Emit($op::Ldc_I4_3)
    $il.Emit($op::Newarr, [object])
    for ($i = 0; $i -lt 3; $i++) {
        $il.Emit($op::Dup)
        $il.Emit($op::Ldc_I4, $i)
        $il.Emit($op::Ldarg, [int16]$i)
        $il.Emit($op::Stelem_Ref)
    }
    $il.Emit($op::Callvirt, [scriptblock].GetMethod('InvokeReturnAsIs'))
    $il.Emit($op::Ret)
    $il.MarkLabel($missingPop)
    $il.Emit($op::Pop)
    $il.MarkLabel($missing)
    $il.Emit($op::Ldstr, 'PSWriteColorEX is not imported in this runspace, so the PSColorStyle method has nothing to run it with. Import the module in this runspace first.')
    $il.Emit($op::Newobj, [System.InvalidOperationException].GetConstructor([type[]]@([string])))
    $il.Emit($op::Throw)

    # Enter and Leave: one more and one fewer import using the type, each returning the count
    $imports = $type.DefineField('imports', [int], [System.Reflection.FieldAttributes]'Private, Static')
    foreach ($counter in @(@('Enter', 'Increment'), @('Leave', 'Decrement'))) {
        $count = $type.DefineMethod($counter[0], [System.Reflection.MethodAttributes]'Private, Static, HideBySig',
            [System.Reflection.CallingConventions]::Standard, [int], [type[]]@())
        $il = $count.GetILGenerator()
        $il.Emit($op::Ldsflda, [System.Reflection.FieldInfo]$imports)
        $il.Emit($op::Call, [System.Threading.Interlocked].GetMethod($counter[1], [type[]]@([int].MakeByRefType())))
        $il.Emit($op::Ret)
    }

    # The methods: arguments in an array, InvokeMember, and what it returns converted
    $getTypeFromHandle = [type].GetMethod('GetTypeFromHandle')
    $convertTo = [System.Management.Automation.LanguagePrimitives].GetMethod('ConvertTo', [type[]]@([object], [type]))
    $hidden = [System.Reflection.Emit.CustomAttributeBuilder]::new([System.Management.Automation.HiddenAttribute].GetConstructor([type[]]@()), [object[]]@())
    foreach ($method in $script:ColorStyleMethods) {
        $attributes = [System.Reflection.MethodAttributes]'Public, HideBySig'
        $callingConvention = [System.Reflection.CallingConventions]::HasThis
        $first = 1
        if ($method.Static) {
            $attributes = $attributes -bor [System.Reflection.MethodAttributes]::Static
            $callingConvention = [System.Reflection.CallingConventions]::Standard
            $first = 0
        }
        $returnType = [void]
        if ($method.Returns -is [string]) {
            $returnType = $type
        } elseif ($null -ne $method.Returns) {
            $returnType = $method.Returns
        }
        $parameterTypes = [type[]]@($method.Parameters.Values)
        $builder = $type.DefineMethod($method.Name, $attributes, $callingConvention, $returnType, $parameterTypes)
        $position = 1
        foreach ($parameter in $method.Parameters.Keys) {
            $null = $builder.DefineParameter($position, [System.Reflection.ParameterAttributes]::None, $parameter)
            $position++
        }
        if ($method.Hidden) {
            $builder.SetCustomAttribute($hidden)
        }
        $il = $builder.GetILGenerator()
        $il.Emit($op::Ldstr, $method.Name)
        if ($method.Static) { $il.Emit($op::Ldnull) } else { $il.Emit($op::Ldarg_0) }
        $il.Emit($op::Ldc_I4, $parameterTypes.Count)
        $il.Emit($op::Newarr, [object])
        for ($i = 0; $i -lt $parameterTypes.Count; $i++) {
            $il.Emit($op::Dup)
            $il.Emit($op::Ldc_I4, $i)
            $il.Emit($op::Ldarg, [int16]($i + $first))
            if ($parameterTypes[$i].IsValueType) {
                $il.Emit($op::Box, $parameterTypes[$i])
            }
            $il.Emit($op::Stelem_Ref)
        }
        $il.Emit($op::Call, [System.Reflection.MethodInfo]$invoke)
        if ($returnType -eq [void]) {
            $il.Emit($op::Pop)
        } elseif ($returnType -ne [object]) {
            $il.Emit($op::Ldtoken, $returnType)
            $il.Emit($op::Call, $getTypeFromHandle)
            $il.Emit($op::Call, $convertTo)
            if ($returnType.IsValueType) {
                $il.Emit($op::Unbox_Any, $returnType)
            } else {
                $il.Emit($op::Castclass, $returnType)
            }
        }
        $il.Emit($op::Ret)
    }

    return $type.CreateType()
}

function Register-ColorStyleType {
    <#
    .SYNOPSIS
    Keeps this runspace's script block for PSColorStyle's methods where the type finds it, and
    counts this import. Returns the name the script block is kept under.

    .DESCRIPTION
    The script block is kept in the process under this runspace's id, through a weak reference,
    so a disposed runspace's module is not held in memory by it.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][type] $Type)

    $key = $script:ColorStyleMemberKey + [runspace]::DefaultRunspace.InstanceId.ToString()
    [System.AppDomain]::CurrentDomain.SetData($key, [System.WeakReference]::new($script:ColorStyleMember))
    $null = $Type.GetMethod('Enter', [System.Reflection.BindingFlags]'NonPublic, Static').Invoke($null, $null)
    return $key
}

function Invoke-ColorStyleMember {
    <#
    .SYNOPSIS
    Runs the PSColorStyle method named, for the style and with the arguments given.
    #>
    [CmdletBinding()]
    [OutputType([hashtable], [bool], [object])]
    [OutputType([PSColorStyle])]
    param(
        [Parameter(Mandatory)][string] $Member,
        [AllowNull()][object] $Style,
        [AllowNull()][object[]] $Arguments
    )

    switch ($Member) {
        'Initialize' { Initialize-ColorStyle -Style $Style -Name $Arguments[0] -Foreground $Arguments[1] -Background $Arguments[2] }
        'SetAsDefault' { [PSColorStyle]::Default = $Style }
        'AddToProfiles' { [PSColorStyle]::Profiles[$Style.Name] = $Style }
        'GetProfile' { Get-ColorStyleProfile -Name $Arguments[0] }
        'InitializeDefaultProfiles' { Initialize-ColorDefaultProfile }
        'ToWriteColorParams' { Get-ColorStyleParameter -Style $Style }
        'InvalidateCache' { }
        'Clone' { Copy-ColorStyle -Style $Style }
        'IsGradient' { Test-ColorStyleGradient -Value $Arguments[0] }
        'CopyValue' { Copy-ColorStyleValue -Value $Arguments[0] }
    }
}

function Initialize-ColorStyle {
    <#
    .SYNOPSIS
    Sets every property of a style as its constructors do: the name and colors given, an empty
    list of styles, a space to pad with, and nothing else set.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object] $Style,
        [AllowNull()][string] $Name,
        [AllowNull()][object] $Foreground,
        [AllowNull()][object] $Background
    )

    $Style.Name = $Name
    $Style.ForegroundColor = $Foreground
    $Style.BackgroundColor = $Background
    $Style.Gradient = $null
    $Style.Style = @()
    $Style.StartTab = 0
    $Style.StartSpaces = 0
    $Style.LinesBefore = 0
    $Style.LinesAfter = 0
    $Style.Bold = $false
    $Style.Italic = $false
    $Style.Underline = $false
    $Style.Blink = $false
    $Style.Faint = $false
    $Style.CrossedOut = $false
    $Style.DoubleUnderline = $false
    $Style.Overline = $false
    $Style.ShowTime = $false
    $Style.NoNewLine = $false
    $Style.HorizontalCenter = $false
    $Style.AutoPad = 0
    $Style.PadLeft = $false
    $Style.PadChar = ' '
    $Style.BackgroundGradient = $null
    $Style.GradientSpace = ''
    $Style.GradientHue = ''
    $Style.GradientEasing = ''
    $Style.GradientRepeat = ''
    $Style.GradientDirection = ''
    $Style.GradientSteps = 0
    $Style.Reverse = $false
    $Style.UnderlineColor = $null
    $Style.UnderlineStyle = ''
    $Style.PadCenter = $false
    $Style.Truncate = $false
    $Style.Wrap = $false
}

function Get-ColorStyleProfile {
    <#
    .SYNOPSIS
    The profile of the name given in [PSColorStyle]::Profiles, or $null.
    #>
    [CmdletBinding()]
    [OutputType([PSColorStyle])]
    param([AllowNull()][string] $Name)

    $styleProfile = [PSColorStyle]::Profiles[$Name]
    if ($styleProfile) {
        return $styleProfile
    }
    return $null
}

function Initialize-ColorDefaultProfile {
    <#
    .SYNOPSIS
    Puts the seven built-in profiles in [PSColorStyle]::Profiles, each one new, and makes the
    Default profile the style -Default applies.
    #>
    [CmdletBinding()]
    param()

    $defaultProfile = [PSColorStyle]::new('Default', 'Gray', $null)
    [PSColorStyle]::Default = $defaultProfile
    [PSColorStyle]::Profiles['Default'] = $defaultProfile

    $errorProfile = [PSColorStyle]::new('Error', 'Red', $null)
    $errorProfile.Bold = $true
    [PSColorStyle]::Profiles['Error'] = $errorProfile

    [PSColorStyle]::Profiles['Warning'] = [PSColorStyle]::new('Warning', 'Yellow', $null)
    [PSColorStyle]::Profiles['Info'] = [PSColorStyle]::new('Info', 'Cyan', $null)
    [PSColorStyle]::Profiles['Success'] = [PSColorStyle]::new('Success', 'Green', $null)

    $criticalProfile = [PSColorStyle]::new('Critical', 'White', 'DarkRed')
    $criticalProfile.Bold = $true
    $criticalProfile.Blink = $true
    [PSColorStyle]::Profiles['Critical'] = $criticalProfile

    $debugProfile = [PSColorStyle]::new('Debug', 'DarkGray', $null)
    $debugProfile.Italic = $true
    [PSColorStyle]::Profiles['Debug'] = $debugProfile
}

function Get-ColorStyleParameter {
    <#
    .SYNOPSIS
    The Write-ColorEX parameters a style sets, read from its properties.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory)][object] $Style)

    $params = @{}

    # A gradient replaces the foreground color
    if ($null -ne $Style.Gradient -and (Test-ColorStyleGradient -Value $Style.Gradient)) {
        $params['Gradient'] = $Style.Gradient
    } elseif ($Style.ForegroundColor) {
        $params['Color'] = $Style.ForegroundColor
    }
    # A background gradient replaces the background color
    if ($null -ne $Style.BackgroundGradient -and (Test-ColorStyleGradient -Value $Style.BackgroundGradient)) {
        $params['BackGroundGradient'] = $Style.BackgroundGradient
    } elseif ($Style.BackgroundColor) {
        $params['BackGroundColor'] = $Style.BackgroundColor
    }
    if ($Style.GradientSpace) { $params['GradientSpace'] = $Style.GradientSpace }
    if ($Style.GradientHue) { $params['GradientHue'] = $Style.GradientHue }
    if ($Style.GradientEasing) { $params['GradientEasing'] = $Style.GradientEasing }
    if ($Style.GradientRepeat) { $params['GradientRepeat'] = $Style.GradientRepeat }
    if ($Style.GradientDirection) { $params['GradientDirection'] = $Style.GradientDirection }
    if ($Style.GradientSteps -gt 0) { $params['GradientSteps'] = $Style.GradientSteps }
    if ($Style.Style.Count -gt 0) { $params['Style'] = $Style.Style }
    if ($Style.StartTab -gt 0) { $params['StartTab'] = $Style.StartTab }
    if ($Style.StartSpaces -gt 0) { $params['StartSpaces'] = $Style.StartSpaces }
    if ($Style.LinesBefore -gt 0) { $params['LinesBefore'] = $Style.LinesBefore }
    if ($Style.LinesAfter -gt 0) { $params['LinesAfter'] = $Style.LinesAfter }
    if ($Style.Bold) { $params['Bold'] = $true }
    if ($Style.Italic) { $params['Italic'] = $true }
    if ($Style.Underline) { $params['Underline'] = $true }
    if ($Style.Blink) { $params['Blink'] = $true }
    if ($Style.Faint) { $params['Faint'] = $true }
    if ($Style.CrossedOut) { $params['CrossedOut'] = $true }
    if ($Style.DoubleUnderline) { $params['DoubleUnderline'] = $true }
    if ($Style.Overline) { $params['Overline'] = $true }
    if ($Style.ShowTime) { $params['ShowTime'] = $true }
    if ($Style.NoNewLine) { $params['NoNewLine'] = $true }
    if ($Style.HorizontalCenter) { $params['HorizontalCenter'] = $true }
    if ($Style.AutoPad -gt 0) { $params['AutoPad'] = $Style.AutoPad }
    if ($Style.PadLeft) { $params['PadLeft'] = $true }
    if ($Style.PadChar -ne ' ') { $params['PadChar'] = $Style.PadChar }
    if ($Style.Reverse) { $params['Reverse'] = $true }
    if ($null -ne $Style.UnderlineColor) { $params['UnderlineColor'] = $Style.UnderlineColor }
    if ($Style.UnderlineStyle) { $params['UnderlineStyle'] = $Style.UnderlineStyle }
    if ($Style.PadCenter) { $params['PadCenter'] = $true }
    if ($Style.Truncate) { $params['Truncate'] = $true }
    if ($Style.Wrap) { $params['Wrap'] = $true }

    return $params
}

function Copy-ColorStyle {
    <#
    .SYNOPSIS
    A copy of a style named with _Copy, property by property. Arrays are copied as well, so
    changing an element of the copy leaves the original alone.
    #>
    [CmdletBinding()]
    [OutputType([PSColorStyle])]
    param([Parameter(Mandatory)][object] $Style)

    $newStyle = [PSColorStyle]::new($Style.Name + '_Copy', (Copy-ColorStyleValue -Value $Style.ForegroundColor), (Copy-ColorStyleValue -Value $Style.BackgroundColor))
    $newStyle.Gradient = Copy-ColorStyleValue -Value $Style.Gradient
    $newStyle.Style = Copy-ColorStyleValue -Value $Style.Style
    $newStyle.StartTab = $Style.StartTab
    $newStyle.StartSpaces = $Style.StartSpaces
    $newStyle.LinesBefore = $Style.LinesBefore
    $newStyle.LinesAfter = $Style.LinesAfter
    $newStyle.Bold = $Style.Bold
    $newStyle.Italic = $Style.Italic
    $newStyle.Underline = $Style.Underline
    $newStyle.Blink = $Style.Blink
    $newStyle.Faint = $Style.Faint
    $newStyle.CrossedOut = $Style.CrossedOut
    $newStyle.DoubleUnderline = $Style.DoubleUnderline
    $newStyle.Overline = $Style.Overline
    $newStyle.ShowTime = $Style.ShowTime
    $newStyle.NoNewLine = $Style.NoNewLine
    $newStyle.HorizontalCenter = $Style.HorizontalCenter
    $newStyle.AutoPad = $Style.AutoPad
    $newStyle.PadLeft = $Style.PadLeft
    $newStyle.PadChar = $Style.PadChar
    $newStyle.BackgroundGradient = Copy-ColorStyleValue -Value $Style.BackgroundGradient
    $newStyle.GradientSpace = $Style.GradientSpace
    $newStyle.GradientHue = $Style.GradientHue
    $newStyle.GradientEasing = $Style.GradientEasing
    $newStyle.GradientRepeat = $Style.GradientRepeat
    $newStyle.GradientDirection = $Style.GradientDirection
    $newStyle.GradientSteps = $Style.GradientSteps
    $newStyle.Reverse = $Style.Reverse
    $newStyle.UnderlineColor = Copy-ColorStyleValue -Value $Style.UnderlineColor
    $newStyle.UnderlineStyle = $Style.UnderlineStyle
    $newStyle.PadCenter = $Style.PadCenter
    $newStyle.Truncate = $Style.Truncate
    $newStyle.Wrap = $Style.Wrap
    return $newStyle
}

function Test-ColorStyleGradient {
    <#
    .SYNOPSIS
    Whether a style's gradient is one Write-ColorEX draws: two colors or more, or the name of a
    named gradient, which the module's table resolves.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()][object[]] $Value)

    if ($null -eq $Value) {
        return $false
    }
    if ($Value.Count -ge 2) {
        return $true
    }
    return $Value.Count -eq 1 -and $Value[0] -is [string] -and $null -ne $script:GradientNames -and $script:GradientNames.Contains([string]$Value[0])
}

function Copy-ColorStyleValue {
    <#
    .SYNOPSIS
    A copy of an array, and of the arrays in it such as RGB colors; any other value as it is.
    #>
    [CmdletBinding()]
    [OutputType([object], [object[]])]
    param([AllowNull()][object] $Value)

    if ($Value -isnot [array]) {
        return $Value
    }
    $copy = $Value.Clone()
    for ($i = 0; $i -lt $copy.Length; $i++) {
        if ($copy[$i] -is [array]) {
            $copy[$i] = $copy[$i].Clone()
        }
    }
    return , $copy
}
