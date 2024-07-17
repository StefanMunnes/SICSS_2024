from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import pandas as pd
from scipy.cluster.hierarchy import linkage, dendrogram
import matplotlib.pyplot as plt

df=pd.read_csv("/Users/ilaria.vitulano/Documents/Weizenbaum/Learning/SICSS/SICSS_2024/exercises/Ilaria_new/day5/exercises/data/CNNsample.csv")

# selecting title
titles = df['title'].tolist()

# 1. Load a pretrained Sentence Transformer model
model = SentenceTransformer("all-MiniLM-L6-v2")

# 2. Calculate embeddings by calling model.encode()
embeddings = model.encode(titles)
print(embeddings.shape)
# [3, 384]

# 3. Calculate the embedding similarities
similarities = cosine_similarity(embeddings)
print(similarities)


# Convert cosine similarities to distances (1 - similarity)
distances = 1 - similarities

# Perform hierarchical clustering
linkage_matrix = linkage(distances, method='ward')

# Plot the dendrogram
plt.figure(figsize=(10, 7))
dendrogram(linkage_matrix, labels=titles, leaf_rotation=90, leaf_font_size=12)
plt.title('Hierarchical Clustering Dendrogram')
plt.xlabel('Titles')
plt.ylabel('Distance')
plt.show()
