using System;
using System.Linq;

namespace OpenTabletDriver.Desktop
{
    public static class Helpers
    {
        /// <summary>
        /// Distribute <paramref name="count"/> into <paramref name="maxCountPerBucket"/> buckets.
        /// Useful for distributing a number of elements into rows and columns.
        /// </summary>
        /// <param name="count">Amount to split into buckets</param>
        /// <param name="maxCountPerBucket">Maximum amount per bucket</param>
        /// <returns>Buckets with the amount of count to take for each element</returns>
        public static int[] SplitIntoBuckets(int count, int maxCountPerBucket = 4)
        {
            ArgumentOutOfRangeException.ThrowIfNegative(count);
            if (count <= maxCountPerBucket) return [count];

            int bucketCount = (int)Math.Ceiling((double)count / maxCountPerBucket);

            // initialize number of elements
            int[] rv = Enumerable.Repeat(0, bucketCount).ToArray();

            int remaining = count;
            int index = 0;
            while (remaining-- > 0)
                rv[index++ % bucketCount] += 1;

            return rv;
        }
    }
}
