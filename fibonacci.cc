#include <iostream>
using std::cin;
using std::cout;
using std::endl;
int main()
{
    int twoBefore = 0, oneBefore = 1, holder;
    int x; // how many times

    cout << "How many numbers of the Fibonacci Sequence would you like to see? (Between 2 and 47)" << endl;
    
    cin >> x;

    cout << "\n" << 0 << endl << 1 << endl;

    for (int i = 0; i < x - 2; i++)
    {
        holder = twoBefore + oneBefore;
        cout << holder << endl;
        twoBefore = oneBefore;
        oneBefore = holder;
    }
}
