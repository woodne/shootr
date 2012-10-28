# How to build this great project?

First, you'll need to install some node packages (I don't have the project manifest created yet, so you 
will have to manually install the dependencies, which isn't too bad). In the root of the project, type

    npm install express http socket.io 

(Express might want to be installed globally, but whatever). 

Then, from anywhere in the project directory (since cake is cool like that) simply run

    cake build

# How do I run this great project?

From the root directory, run 

    node lib/main.js

And the server will start running! Then navigate to wherever you hosted it on port 6543. For instance, if you run it on your local machine, go to <http://localhost:6543/>

Nothing else of note yet...