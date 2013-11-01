def de_bruijn(k, n):
    """
    De Bruijn sequence for alphabet size k 
    and subsequences of length n.
    """
    a = [0] * k * n
    sequence = []
    def db(t, p):
        if t > n:
            if n % p == 0:
                for j in range(1, p + 1):
                    sequence.append(a[j])
        else:
            a[t] = a[t - p]
            db(t + 1, p)
            for j in range(a[t - p] + 1, k):
                a[t] = j
                db(t + 1, t)
    db(1, 1)
    return sequence
 
if __name__ == "__main__":
    k = 2
    n = 5
    print de_bruijn(k,n)
