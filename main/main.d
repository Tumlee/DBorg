import std.stdio;
import std.algorithm;
import std.range;
import DBorg;

string getparm(string args[], string name)
{
    foreach(a; 1 .. args.length - 1)
    {
        if(args[a] == name)
            return args[a + 1];
    }

    return null;
}

bool getswitch(string args[], string name)
{
    return args[1 .. $].canFind(name);
}

bool load_lines(DBorg bot, string filename)
{
    //Open the file.
    File botfile;

    try
    {
        botfile = File(filename, "r");
    }
    catch(std.exception.ErrnoException)
    {
        return false;
    }

    string line;

    while((line = botfile.readln()) !is null)
        bot.learn(line);

    botfile.close();
    return true;
}

bool save_lines(DBorg bot, string filename)
{
    File outfile;

    try
    {
        outfile = File(filename, "w");
    }
    catch(std.exception.ErrnoException)
    {
        return false;
    }

    foreach(sentence; bot.sentences)
         outfile.writeln(sentence.joiner(" ").array);

    outfile.close();
    return true;
}

void main(string args[])
{
    auto bot = new DBorg;

    string replytopic = getparm(args, "--topic");
    string replyinput = getparm(args, "--reply");
    string filename = getparm(args, "--file");
    bool statmode = getswitch(args, "--stats");
    bool learning = !getswitch(args, "--no-learning");
    bool savelines = getswitch(args, "--save-lines");

    if(filename is null)
        filename = "lines.txt";

    bot.load_lines(filename);

    if(replytopic !is null)
    {
        writeln(bot.say_topic(replytopic));
        return;
    }

    if(replyinput !is null)
    {
        writeln(bot.reply(replyinput));
        return;
    }

    if(statmode)
    {
        writefln("%d words", bot.words.length);
        writefln("%d cleanwords", bot.cleanwords.length);
        writefln("%d sentences", bot.sentences.length);
        return;
    }

    while(true)
    {
        write("<You> ");

        string input = readln();

        if(input == null)
            break;

        writefln("<Bot> %s", bot.reply(input));

        if(learning)
            bot.learn(input);
    }

    if(savelines)
        bot.save_lines(filename);
}
