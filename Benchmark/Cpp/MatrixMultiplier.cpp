#include <vector>
#include <iostream>
#include <chrono>
#include <cstdlib>
#include <fstream>

using namespace std;


class MatrixMult {

public:

    vector<vector<int>> MatrixMultiply(
        vector<vector<int>>& A,
        vector<vector<int>>& B
    ) {

        int n = A.size();

        vector<vector<int>> C(n, vector<int>(n, 0));

        for (int row = 0; row < n; row++) {
            for (int col = 0; col < n; col++) {
                for (int k = 0; k < n; k++) {
                    C[row][col] += A[row][k] * B[k][col];
                }
            }
        }

        return C;
    }
};


vector<vector<int>> generateMatrix(int n) {

    vector<vector<int>> matrix(n, vector<int>(n));

    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            matrix[i][j] = rand() % 10;
        }
    }

    return matrix;
}


int main() {

    fstream output("Cpp_results.txt");

    MatrixMult multiplier;

    int matrix_sizes[] = {16, 32, 64, 128, 256};

    int num_runs = 5;

    output << "C++ Matrix Multiplication Benchmark Results:" << endl;

    for (int n : matrix_sizes) {

        double total_time = 0;

        vector<vector<int>> A = generateMatrix(n);
        vector<vector<int>> B = generateMatrix(n);

        cout << "\n" << n << "x" << n << endl;
        output << n << "x" << n << endl;

        for (int run = 0; run < num_runs; run++) {

            auto start = chrono::high_resolution_clock::now();

            vector<vector<int>> result =
                multiplier.MatrixMultiply(A, B);

            auto end = chrono::high_resolution_clock::now();

            chrono::duration<double, milli> elapsed =
                end - start;

            total_time += elapsed.count();

            cout << "Run " << run + 1
                 << ": " << elapsed.count()
                 << " ms" << endl;


            output << "Run " << run + 1
                << ": " << elapsed.count()
                << " ms" << endl;
        }

        double average_time = total_time / num_runs;

        cout << "Average: "
             << average_time
             << " ms" << endl;

        output << n << "x" << n
               << " Average: "
               << average_time
               << " ms" << endl;
        output << endl;
    }

    output.close();

}