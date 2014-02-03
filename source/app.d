import std.stdio;
import std.zlib;
import std.getopt;
import std.regex;
import std.file;
import std.exception;
import std.string;
import std.array;
import std.conv;
private import stdlib = core.stdc.stdlib : exit;

//int nextFile;

void main(string[] args)
{
    string pathToPdf;
    string dataBase;

/*
    getopt(args,
           "input|i", &pathToPdf,
           "output|o", &dataBase);
*/
    if(args.length == 1){
        write("Input file: ");
        pathToPdf= chomp(readln());
    }
    writeln(pathToPdf);
    try {
        //writeln(getStreams(getObj(readFiles(pathToPdf))));
        getStreams(getObj(pathToPdf));
        //writeln(getObj(pathToPdf));
    }
    catch(FileException fexc)
    {
        writeln("File not found in ", getcwd());
        exitProg(0);
    }
    catch(ErrnoException oexc)
    {
        writeln("Cannot open file ");
        exitProg(0);
    }
}

string[] getObj(in string fileName) {
	auto regexObj= regex(`obj(.*)endobj`, "g");
	string[] allObjects;
    File f= File(fileName, "r");
    string str;
    uint bufferSize= to!uint(f.size);
    char[] buffer;
    uint i= 0;
    buffer.length= bufferSize;
    f.rawRead(buffer);
    //f.read(" %s", &buffer[i]);
    str~=buffer;
    writeln(str.length);
    //string buffer= join(buffer);
	auto matches = match(str, regexObj); // --------------- ISSUE HERE
    assert(matches);
	foreach(cap; matches.captures) {
	  allObjects~= cap;
	}
    return allObjects;
}
unittest{
    auto matches= match("obj1234567890endobj", regex(`obj(.*)endobj`, "g"));
    assert(matches);
    assert(matches.captures[1] == "1234567890");

}

string[] getStreams(in string[] objects) {
    string[] allStreams;
    auto regexProp= regex(`<</Length(\s\d*)/Filter/FlateDecode>>`, "g");
    auto regexStream= regex(`stream(.*)endstream`, "g");
    //проверяем блоки свойств каждого обьекта на соответствие текстовому потоку
        //при совпадении - добавляем поток к результату
    foreach(obj; objects){
        if (match(obj, regexProp)) {
            auto m2 = match(obj, regexStream);
            assert(m2);
            allStreams~= m2.captures[1];
        }
    }
    return allStreams;
}
unittest{

}

string readFiles(in string pathToPdf){
    File inputFile;
    if(pathToPdf.exists){
        if(!pathToPdf.isDir){
            inputFile= File(pathToPdf, "r");
        }
    }
    //inputFile.checkPDF();
    //nextFile++;
    string fileName= inputFile.name;
    inputFile.detach;
    return fileName;
    //return &inputFile;
}
unittest{


}

ref void writeResult(in string dataBase, in string[] result){
    File outputFile;
    if(!dataBase.exists){
        outputFile= File(dataBase, "w");
    }
    else{
        outputFile= File(dataBase, "a");
    }
    outputFile.writeln(result);
}
unittest{

}

void exitProg(in int state){
    stdlib.exit(state);
}
