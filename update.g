#
# GitHubPagesForGAP - a template for using GitHub Pages within GAP packages
#
# Copyright (c) 2013-2018 Max Horn
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#

# Parse PackageInfo.g and regenerate _data/package.yml from it.

PrintPeopleList := function(stream, people)
    local p;
    for p in people do
        AppendTo(stream, "    - name: ", p.FirstNames, " ", p.LastName, "\n");
        if IsBound(p.WWWHome) then
            AppendTo(stream, "      url: ", p.WWWHome, "\n");
        elif IsBound(p.Email) then
            AppendTo(stream, "      url: mailto:", p.Email, "\n");
        fi;
    od;
    AppendTo(stream, "\n");
end;

PrintPackageList := function(stream, pkgs)
    local p, pkginfo;
    for p in pkgs do
        AppendTo(stream, "    - name: \"", p[1], "\"\n");
        AppendTo(stream, "      version: \"", p[2], "\"\n");
        pkginfo := PackageInfo(p[1]);
        if Length(pkginfo) > 0 and IsBound(pkginfo[1].PackageWWWHome) then
            AppendTo(stream, "      url: \"", pkginfo[1].PackageWWWHome, "\"\n");
        fi;
    od;
    AppendTo(stream, "\n");
end;

# verify date is of the form YYYY-MM-DD
IsValidISO8601Date := function(date)
    local day, month, year;
    if Length(date) <> 10 then return false; fi;
    if date[5] <> '-' or date[8] <> '-' then return false; fi;
    if not ForAll(date{[1,2,3,4,6,7,9,10]}, IsDigitChar) then
        return false;
    fi;
    date := List(SplitString(date, "-"), Int);
    day := date[3];
    month := date[2];
    year := date[1];
    return month in [1..12] and day in [1..DaysInMonth(month, year)];
end;

GeneratePackageYML:=function(pkg)
    local stream, date, authors, maintainers, contributors, formats, f, tmp;

    stream := OutputTextFile("_data/package.yml", false);
    SetPrintFormattingStatus(stream, false);
    
    AppendTo(stream, "name: ", pkg.PackageName, "\n");
    AppendTo(stream, "version: ", pkg.Version, "\n");

    # convert date from DD/MM/YYYY to ISO 8601, i.e. YYYY-MM-DD
    #
    # in the future, GAP might support ISO 8601 dates in PackageInfo.g,
    # so be prepared to accept that
    date := pkg.Date;
    tmp := SplitString(pkg.Date, "/");
    if Length(tmp) = 3 then
        # pad month and date if necessary
        if Length(tmp[1]) = 1 then
          tmp[1] := Concatenation("0", tmp[1]);
        fi;
        if Length(tmp[2]) = 1 then
          tmp[2] := Concatenation("0", tmp[2]);
        fi;
        date := Concatenation(tmp[3], "-", tmp[2], "-", tmp[1]);
    fi;
    if not IsValidISO8601Date(date) then
        Error("malformed release date ", pkg.Date);
    fi;

    AppendTo(stream, "date: ", date, "\n");
    AppendTo(stream, "description: |\n");
    AppendTo(stream, "    ", pkg.Subtitle, "\n");
    AppendTo(stream, "\n");

    authors := Filtered(pkg.Persons, p -> p.IsAuthor);
    if Length(authors) > 0 then
        AppendTo(stream, "authors:\n");
        PrintPeopleList(stream, authors);
    fi;

    maintainers := Filtered(pkg.Persons, p -> p.IsMaintainer);
    if Length(maintainers) > 0 then
        AppendTo(stream, "maintainers:\n");
        PrintPeopleList(stream, maintainers);
    fi;

    contributors := Filtered(pkg.Persons, p -> not p.IsMaintainer and not p.IsAuthor);
    if Length(contributors) > 0 then
        AppendTo(stream, "contributors:\n");
        PrintPeopleList(stream, contributors);
    fi;

    if IsBound(pkg.Dependencies.GAP) then
        AppendTo(stream, "GAP: \"", pkg.Dependencies.GAP, "\"\n\n");
    fi;

    if IsBound(pkg.Dependencies.NeededOtherPackages) and
        Length(pkg.Dependencies.NeededOtherPackages) > 0 then
        AppendTo(stream, "needed-pkgs:\n");
        PrintPackageList(stream, pkg.Dependencies.NeededOtherPackages);
    fi;

    if IsBound(pkg.Dependencies.SuggestedOtherPackages) and
        Length(pkg.Dependencies.SuggestedOtherPackages) > 0 then
        AppendTo(stream, "suggested-pkgs:\n");
        PrintPackageList(stream, pkg.Dependencies.SuggestedOtherPackages);
    fi;

    AppendTo(stream, "www: ", pkg.PackageWWWHome, "\n");
    tmp := SplitString(pkg.README_URL,"/");
    tmp := tmp[Length(tmp)];  # extract README filename (typically "README" or "README.md")
    AppendTo(stream, "readme: ", tmp, "\n");
    AppendTo(stream, "packageinfo: ", pkg.PackageInfoURL, "\n");
    if IsBound(pkg.GithubWWW) then
        AppendTo(stream, "github: ", pkg.GithubWWW, "\n");
    fi;
    AppendTo(stream, "\n");
    
    formats := SplitString(pkg.ArchiveFormats, " ");
    if Length(formats) > 0 then
        AppendTo(stream, "downloads:\n");
        for f in formats do
            AppendTo(stream, "    - name: ", f, "\n");
            AppendTo(stream, "      url: ", pkg.ArchiveURL, f, "\n");
        od;
        AppendTo(stream, "\n");
    fi;

    AppendTo(stream, "abstract: |\n");
    for tmp in SplitString(pkg.AbstractHTML,"\n") do
        AppendTo(stream, "    ", tmp, "\n");
    od;
    AppendTo(stream, "\n");

    AppendTo(stream, "status: ", pkg.Status, "\n");
    if IsRecord(pkg.PackageDoc) then
        AppendTo(stream, "doc-html: ", pkg.PackageDoc.HTMLStart, "\n");
        AppendTo(stream, "doc-pdf: ", pkg.PackageDoc.PDFFile, "\n");
    else
        Assert(0, IsList(pkg.PackageDoc));
        AppendTo(stream, "doc-html: ", pkg.PackageDoc[1].HTMLStart, "\n");
        AppendTo(stream, "doc-pdf: ", pkg.PackageDoc[1].PDFFile, "\n");
        if Length(pkg.PackageDoc) > 1 then
            Print("Warning, this package has more than one help book!\n");
        fi;
    fi;

    # TODO: use Keywords?

    CloseStream(stream);
end;
Read("PackageInfo.g");
GeneratePackageYML(GAPInfo.PackageInfoCurrent);
QUIT;
