Param ($name, $language = "C#", $framework = "netstandard2.0", $appFramework = "netcoreapp3.1", $outputDir = $name);
$testProjectName = "$name.Tests";

#scaffold necessary projects, solution with solution folders, and project references
dotnet new classlib -n $name -o $outputDir/src/$name -f $framework -lang $language;
dotnet new nunit -n $testProjectName -o $outputDir/tests/$testProjectName -f $appFramework -lang $language;
dotnet new sln -n $name -o $outputDir;
dotnet sln $outputDir/$name.sln add $outputDir/src/$name/$name.csproj -s "src"; 
dotnet sln $outputDir/$name.sln add $outputDir/tests/$testProjectName/$testProjectName.csproj -s "tests";
dotnet add $outputDir/tests/$testProjectName/$testProjectName.csproj reference $outputDir/src/$name/$name.csproj;

#Add Assembly Info and mark source project's internals visible to the test project.
# Don't think there's a CLI method of adding the file, so use content add for now directly.
$assemblyGuid = [System.Guid]::NewGuid().ToString();
$assemblyInfoContent = "
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

// In SDK-style projects such as this one, several assembly attributes that were historically
// defined in this file are now automatically added during build and populated with
// values defined in project properties. For details of which attributes are included
// and how to customise this process see: https://aka.ms/assembly-info-properties


// Setting ComVisible to false makes the types in this assembly not visible to COM
// components.  If you need to access a type in this assembly from COM, set the ComVisible
// attribute to true on that type.

[assembly: ComVisible(false)]

// The following GUID is for the ID of the typelib if this project is exposed to COM.

[assembly: Guid(""$assemblyGuid"")]
[assembly: InternalsVisibleTo(""$testProjectName"")]";

Add-Content -Path $outputDir/src/$name/AssemblyInfo.cs -Value $assemblyInfoContent

#build and test for good measure to make sure everything works out of the gate.
dotnet build $outputDir/$name.sln;
dotnet test $outputDir/tests/$testProjectName/$testProjectName.csproj;