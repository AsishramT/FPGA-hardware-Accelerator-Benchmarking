import random
import time


class MatrixMult:

    def MatrixMultiply(self, A, B):
        n = len(A)

        C = [[0 for _ in range(n)] for _ in range(n)]

        for row in range(n):
            for col in range(n):
                for k in range(n):
                    C[row][col] += A[row][k] * B[k][col]

        return C


def generateMatrix(n):
    matrix = []

    for i in range(n):
        row = []

        for j in range(n):
            row.append(random.randint(0, 9))

        matrix.append(row)

    return matrix


def main():

    output = open("py_results.txt", "w")

    multiplier = MatrixMult()

    matrix_sizes = [16, 32, 64, 128, 256]

    num_runs = 5

    output.write("Python Matrix Multiplication Benchmark Results:\n\n")

    for n in matrix_sizes:

        total_time = 0

        A = generateMatrix(n)
        B = generateMatrix(n)

        print(f"\n{n}x{n}")
        output.write(f"{n}x{n}\n")

        for run in range(num_runs):

            start = time.perf_counter()

            result = multiplier.MatrixMultiply(A, B)

            end = time.perf_counter()

            elapsed = (end - start) * 1000

            total_time += elapsed

            # Terminal
            print(f"Run {run + 1}: {elapsed:.6f} ms")

            # File
            output.write(
                f"Run {run + 1}: {elapsed:.6f} ms\n"
            )

        # Calculate average
        average_time = total_time / num_runs

        # Terminal
        print(f"Average: {average_time:.6f} ms")

        # File
        output.write(
            f"Average: {average_time:.6f} ms\n"
        )

        output.write("\n")

    output.close()


if __name__ == "__main__":
    main()